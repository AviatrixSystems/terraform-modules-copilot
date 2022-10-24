variable "project_id" {
  type        = string
  description = "project ID"
}

variable "service_account_private_key" {
  type        = string
  description = "service account private key path"
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

variable "controller_network_tag" {
  type        = string
  description = "controller network tag"
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

variable "main_copilot_network_tag" {
  type        = string
  description = "main copilot network tag"
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

variable "node_copilot_network_tags" {
  type        = list(string)
  description = "list of node copilot network tags"
}
