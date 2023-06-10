resource "google_compute_network" "copilot_network" {
  count                   = var.use_existing_network == false ? 1 : 0
  name                    = "aviatrix-copilot-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "copilot_subnet" {
  count         = var.use_existing_network == false ? 1 : 0
  name          = "aviatrix-copilot-subnetwork"
  network       = google_compute_network.copilot_network[0].self_link
  ip_cidr_range = var.subnet_cidr
}

resource "google_compute_address" "ip_address" {
  name         = var.ip_address_name
  address_type = "EXTERNAL"
}

resource "tls_private_key" "key_pair_material" {
  count     = var.ssh_user == "" ? 0 : (var.use_existing_ssh_key == false ? 1 : 0)
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "http" "image_info" {
  url = "https://release.prod.sre.aviatrix.com/image-details/gcp_copilot_image_details.json"
  request_headers = {
    "Accept" = "application/json"
  }
}

resource "google_compute_instance" "copilot" {
  name         = var.copilot_name
  machine_type = var.copilot_machine_type
  tags         = var.network_tags

  boot_disk {
    initialize_params {
      image = var.image == "" ? jsondecode(data.http.image_info.response_body)["BYOL"] : var.image
      size  = var.boot_disk_size
    }
  }

  service_account {
    email  = var.service_account_email
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

  metadata_startup_script = local.metadata_startup_script

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

resource "google_compute_firewall" "copilot_firewall" {
  name          = each.key
  network       = var.use_existing_network == false ? google_compute_network.copilot_network[0].self_link : var.network
  for_each      = var.allowed_cidrs
  source_ranges = each.value["cidrs"]
  target_tags   = google_compute_instance.copilot.tags

  allow {
    protocol = each.value["protocol"]
    ports    = [each.value["port"]]
  }
}

resource "google_compute_disk" "default" {
  count = var.default_data_disk_size == 0 ? 0 : 1
  name  = var.default_data_disk_name
  size  = var.default_data_disk_size
}

resource "google_compute_attached_disk" "default" {
  count    = var.default_data_disk_size == 0 ? 0 : 1
  disk     = google_compute_disk.default[0].id
  instance = google_compute_instance.copilot.id
}

resource "google_compute_attached_disk" "disk_att" {
  for_each = var.additional_disks
  disk     = each.value
  instance = google_compute_instance.copilot.id
}
