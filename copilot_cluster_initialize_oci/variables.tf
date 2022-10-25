variable "user_id" {
  type        = string
  description = "user ID"
}

variable "tenancy_id" {
  type        = string
  description = "tenancy ID"
}

variable "fingerprint" {
  type        = string
  description = "fingerprint"
}

variable "key_file" {
  type        = string
  description = "key file path"
}

variable "region" {
  type        = string
  description = "region"
}

variable "controller_public_ip" {
  type        = string
  description = "controller public IP"
  default     = "0.0.0.0"
}

variable "controller_private_ip" {
  type        = string
  description = "controller private IP"
}

variable "controller_username" {
  type        = string
  description = "controller username"
}

variable "controller_password" {
  type        = string
  description = "controller password"
}

variable "controller_nsg_id" {
  type        = string
  description = "controller nsg ID"
}

variable "main_copilot_public_ip" {
  type        = string
  description = "main copilot public IP"
  default     = "0.0.0.0"
}

variable "main_copilot_private_ip" {
  type        = string
  description = "main copilot private IP"
}

variable "main_copilot_username" {
  type        = string
  description = "main copilot username"
}

variable "main_copilot_password" {
  type        = string
  description = "main copilot password"
}

variable "main_copilot_nsg_id" {
  type        = string
  description = "main copilot nsg ID"
}

variable "node_copilot_public_ips" {
  type        = list(string)
  description = "list of node copilot public IPs"
  default     = ["0.0.0.0"]
}

variable "node_copilot_private_ips" {
  type        = list(string)
  description = "list of node copilot private IPs"
}

variable "node_copilot_usernames" {
  type        = list(string)
  description = "list of node copilot usernames"
}

variable "node_copilot_passwords" {
  type        = list(string)
  description = "list of node copilot passwords"
}

variable "node_copilot_names" {
  type        = list(string)
  description = "list of node copilot names"
}

variable "node_copilot_nsg_ids" {
  type        = list(string)
  description = "list of node copilot nsg IDs"
}
