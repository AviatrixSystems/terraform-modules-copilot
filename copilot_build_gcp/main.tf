resource "google_compute_network" "copilot_network" {
  count = var.use_existing_network == false ? 1 : 0
  name = "aviatrix-copilot-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "copilot_subnet" {
  count = var.use_existing_network == false ? 1 : 0
  name = "aviatrix-copilot-subnetwork"
  network = google_compute_network.copilot_network[0].self_link
  ip_cidr_range = var.subnet_cidr
}

resource "google_compute_address" "ip_address" {
  name = "aviatrix-copilot-address"
  address_type = "EXTERNAL"
}

resource "tls_private_key" "key_pair_material" {
  count     = var.use_existing_ssh_key == false ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance" "copilot" {
  name = var.copilot_name
  machine_type = var.copilot_machine_type

  boot_disk {
    initialize_params {
      image = "aviatrix-public/avx-copilot-gcp-1-3-1-2020-12-09"
    }
  }

  service_account {
    email = var.service_account_email
    scopes = var.service_account_scopes
  }

  network_interface {
    subnetwork = var.use_existing_network == false ? google_compute_subnetwork.copilot_subnet[0].self_link : var.subnetwork

    access_config {
      nat_ip = google_compute_address.ip_address.address
    }
  }

  metadata = {
    ssh-keys = local.ssh_key
  }
}

resource "google_compute_firewall" "copilot_firewall" {
  name = each.key
  network = var.use_existing_network == false ? google_compute_network.copilot_network[0].self_link : var.network
  for_each = var.allowed_cidrs
  source_ranges = each.value["cidrs"]

  allow {
    protocol = each.value["protocol"]
    ports = [each.value["port"]]
  }
}
