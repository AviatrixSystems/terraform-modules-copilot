variable "location" {
  type        = string
  description = "Resource Group Location for Aviatrix Copilot"
  default     = "West US"
}

variable "copilot_name" {
  type        = string
  description = "Customized Name for Aviatrix Copilot"
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR for copilot VNET"
  default     = "10.0.0.0/24"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR for copilot subnet"
  default     = "10.0.0.0/24"
}

variable use_existing_vnet {
  type        = bool
  description = "Flag to indicate whether to use an existing VNET"
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name, only required when use_existing_vnet is true"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID, only required when use_existing_vnet is true"
  default     = ""
}

variable "virtual_machine_admin_username" {
  type        = string
  description = "Admin Username for the copilot virtual machine"
}

variable "virtual_machine_admin_password" {
  type        = string
  description = "Admin Password for the copilot virtual machine"
}

variable "virtual_machine_size" {
  type        = string
  description = "Virtual Machine size for the copilot"
  default     = "Standard_A4_v2"
}

variable allowed_cidrs {
  type = map(object({
    priority = string,
    protocol = string,
    ports    = set(string),
    cidrs    = set(string),
  }))
}

variable "os_disk_name" {
  type        = string
  default     = "aviatrix-os-disk"
  description = "OS disk name of the copilot virtual machine"
}

variable additional_disks {
  default = {}
  type = map(object({
    managed_disk_id = string,
    lun = string,
  }))
}
