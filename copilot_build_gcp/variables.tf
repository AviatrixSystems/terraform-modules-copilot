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

variable "default_data_disk_size" {
  default     = 0
  type        = number
  description = "Size of default data disk. If not set, no default data disk will be created."
}

variable "additional_disks" {
  type    = set(string)
  default = []

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

locals {
  ssh_key = var.ssh_user == "" ? "" : (var.use_existing_ssh_key == false ? "${var.ssh_user}:${tls_private_key.key_pair_material[0].public_key_openssh}" : "${var.ssh_user}:${file(var.ssh_public_key_file_path)}")
}
