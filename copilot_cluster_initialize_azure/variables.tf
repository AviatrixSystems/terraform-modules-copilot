variable "subscription_id" {
  type        = string
  description = "subscription ID"
}

variable "client_id" {
  type        = string
  description = "client ID"
}

variable "client_secret" {
  type        = string
  description = "client secret"
}

variable "tenant_id" {
  type        = string
  description = "tenant ID"
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

variable "controller_resource_group_name" {
  type        = string
  description = "controller resource group name"
}

variable "controller_network_security_group_name" {
  type        = string
  description = "controller network security group name"
}

variable "controller_security_rule_name" {
  type        = string
  description = "controller security rule name"
}

variable "controller_security_rule_priority" {
  type        = number
  description = "controller security rule priority"
}

variable "copilot_cluster_resource_group_name" {
  type        = string
  description = "copilot cluster resource group name"
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

variable "main_copilot_network_security_group_name" {
  type        = string
  description = "main copilot network security group name"
}

variable "main_copilot_security_rule_name" {
  type        = string
  description = "main copilot security rule name"
}

variable "main_copilot_security_rule_priority" {
  type        = number
  description = "main copilot security rule priority"
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

variable "node_copilot_network_security_group_names" {
  type        = list(string)
  description = "list of node copilot network security group names"
}

variable "node_copilot_security_rule_names" {
  type        = list(string)
  description = "list of node copilot security rule names"
}

variable "node_copilot_security_rule_priorities" {
  type        = list(number)
  description = "list of node copilot security rule priorities"
}

variable "private_mode" {
  type        = bool
  description = "in private mode or not"
  default     = false
}

locals {
  validate_public_ips = (var.private_mode == false && (var.controller_public_ip == "0.0.0.0" || var.main_copilot_public_ip == "0.0.0.0" || tolist(var.node_copilot_public_ips) == tolist(["0.0.0.0"]))) ? tobool("Please pass in valid controller_public_ip, main_copilot_public_ip and node_copilot_public_ips when private_mode is false.") : true
}
