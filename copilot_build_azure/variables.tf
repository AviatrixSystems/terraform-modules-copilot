variable "location" {
  type        = string
  description = "Resource Group Location for Aviatrix Copilot"
  default     = "West US"
}

variable "copilot_name" {
  type        = string
  description = "Customized Name for Aviatrix Copilot"
}

variable "copilot_vnet_cidr" {
  type        = string
  description = "CIDR for copilot VNET."
  default     = "10.0.0.0/24"
}

variable "copilot_subnet_cidr" {
  type        = string
  description = "CIDR for copilot subnet."
  default     = "10.0.0.0/24"
}

variable "copilot_virtual_machine_admin_username" {
  type        = string
  description = "Admin Username for the copilot virtual machine."
  default     = "aviatrix"
}

variable "copilot_virtual_machine_admin_password" {
  type        = string
  description = "Admin Password for the copilot virtual machine."
  default     = "aviatrix1234!"
}

variable "copilot_virtual_machine_size" {
  type        = string
  description = "Virtual Machine size for the copilot."
  default     = "Standard_A4_v2"
}

variable "incoming_ssl_cidrs" {
  type        = list(string)
  description = "Incoming CIDRs allowed for HTTPS access."
}
