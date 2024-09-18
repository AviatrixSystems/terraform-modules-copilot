variable "avx_controller_public_ip" {
  type = string
  description = "The public IP address of the Aviatrix Controller"
}

variable "avx_copilot_public_ip" {
  type = string
  description = "The public IP address of the Aviatrix CoPilot"
}

variable "avx_controller_username" {
  type = string
  description = "The username to login to the Aviatrix Controller"
}

variable "avx_controller_password" {
  type = string
  description = "The password to login to the Aviatrix Controller"
}

variable "copilot_service_account_username" {
  type = string
  description = "The username to login to the Aviatrix CoPilot"
}

variable "copilot_service_account_password" {
  type = string
  description = "The password to login to the Aviatrix CoPilot"
}
