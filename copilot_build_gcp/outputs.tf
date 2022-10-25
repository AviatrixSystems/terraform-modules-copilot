output "public_ip" {
  value = google_compute_instance.copilot.network_interface[0].access_config[0].nat_ip
}

output "private_ip" {
  value = google_compute_instance.copilot.network_interface[0].network_ip
}

output "instance_id" {
  value = google_compute_instance.copilot.instance_id
}

output "network" {
  value = var.use_existing_network ? var.network : google_compute_network.copilot_network[0].self_link
}
