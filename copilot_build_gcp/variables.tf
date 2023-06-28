variable "use_existing_network" {
  type        = bool
  description = "Flag to indicate whether to use an existing network"
  default     = false
}

variable "network" {
  type        = string
  description = "The network to attach to the Aviatrix Copilot"
  default     = ""
}

variable "subnetwork" {
  type        = string
  description = "The subnetwork to attach the Aviatrix Copilot"
  default     = ""
}

variable "subnet_cidr" {
  type        = string
  description = "The cidr for the subnetwork this module will create or an existing subnet"
  default     = "10.128.0.0/9"
}

variable "allowed_cidrs" {
  type = map(object({
    protocol = string,
    port     = number
    cidrs    = set(string),
  }))
}

variable "copilot_name" {
  type        = string
  description = "The Aviatrix Copilot name"
  default     = "aviatrix-copilot"
}

variable "service_account_email" {
  type        = string
  description = "The Service Account to assign to the Aviatrix Copilot"
  default     = ""
}

variable "service_account_scopes" {
  type        = set(string)
  description = "The scopes to assign to the Aviatrix Copilot's Service Account"
  default     = ["cloud-platform"]
}

variable "copilot_machine_type" {
  type        = string
  description = "The machine type to create the Aviatrix Copilot"
  default     = "e2-standard-2"
}

variable "ssh_user" {
  type        = string
  description = "SSH user name"
  default     = ""
}

variable "use_existing_ssh_key" {
  type        = bool
  description = "Flag to indicate whether to use an existing ssh key"
  default     = false
}

variable "ssh_public_key_file_path" {
  type        = string
  description = "File path to the SSH public key"
  default     = ""
}

variable "ssh_public_key_file_content" {
  type        = string
  description = "File content of the SSH public key"
  default     = ""
}

variable "default_data_disk_size" {
  type        = number
  description = "Size of default data disk. If not set, no default data disk will be created."
  default     = 0
}

variable "default_data_disk_name" {
  type        = string
  description = "Name of default data disk. If default data disk is not created, this variable will be ignored."
  default     = "default-data-disk"
}

variable "additional_disks" {
  type        = set(string)
  description = "A set of additional disks' `name` or `self_link` that will be attached to the copilot instance"
  default     = []
}

variable "boot_disk_size" {
  type        = number
  description = "Boot disk size for copilot"
  default     = 30

  validation {
    condition     = var.boot_disk_size >= 30
    error_message = "The minimum boot disk volume size is 30G."
  }
}

variable "network_tags" {
  type        = set(string)
  description = "Compute instance network tags"
  default     = ["copilot"]
}

variable "private_mode" {
  type        = bool
  description = "Flag to indicate whether the copilot is for private mode"
  default     = false
}

variable "is_cluster" {
  type        = bool
  description = "Flag to indicate whether the copilot is for a cluster"
  default     = false
}

variable "controller_public_ip" {
  type        = string
  description = "Controller public IP"
  default     = "0.0.0.0"
}

variable "controller_private_ip" {
  type        = string
  description = "Controller private IP"
}

locals {
  ssh_key             = var.ssh_user == "" ? "" : (var.use_existing_ssh_key == false ? "${var.ssh_user}:${tls_private_key.key_pair_material[0].public_key_openssh}" : (var.ssh_public_key_file_path != "" ? "${var.ssh_user}:${file(var.ssh_public_key_file_path)}" : "${var.ssh_user}:${var.ssh_public_key_file_content}"))
  controller_ip       = var.private_mode ? var.controller_private_ip : var.controller_public_ip
  validate_public_ips = (var.private_mode == false && var.controller_public_ip == "0.0.0.0") ? tobool("Please pass in valid controller_public_ip when private_mode is false.") : true

  metadata_startup_script = <<EOF
#!/bin/bash
jq '.config.controllerIp="${local.controller_ip}" | .config.controllerPublicIp="${local.controller_ip}" | .config.isCluster=${var.is_cluster}' /etc/copilot/db.json > /etc/copilot/db.json.tmp
mv /etc/copilot/db.json.tmp /etc/copilot/db.json
EOF
}

variable "ip_address_name" {
  type        = string
  description = "IP address name"
  default     = "aviatrix-copilot-address"
}

variable "image" {
  type        = string
  description = "Image name"
  default     = ""
}
