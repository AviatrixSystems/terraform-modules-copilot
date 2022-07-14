variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
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

variable "controller_region" {
  type        = string
  description = "controller region"
}

variable "controller_username" {
  type        = string
  description = "controller username"
}

variable "controller_password" {
  type        = string
  description = "controller password"
}

variable "controller_sg_name" {
  type        = string
  description = "controller security group name"
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

variable "main_copilot_region" {
  type        = string
  description = "main copilot region"
}

variable "main_copilot_username" {
  type        = string
  description = "main copilot username"
}

variable "main_copilot_password" {
  type        = string
  description = "main copilot password"
}

variable "main_copilot_sg_name" {
  type        = string
  description = "main copilot security group name"
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

variable "node_copilot_regions" {
  type        = list(string)
  description = "list of node copilot regions"
}

variable "node_copilot_usernames" {
  type        = list(string)
  description = "list of node copilot usernames"
}

variable "node_copilot_passwords" {
  type        = list(string)
  description = "list of node copilot passwords"
}

variable "node_copilot_data_volumes" {
  type        = list(string)
  description = "list of node copilot data volumes"
}

variable "node_copilot_names" {
  type        = list(string)
  description = "list of node copilot names"
}

variable "node_copilot_sg_names" {
  type        = list(string)
  description = "list of node copilot security group names"
}

variable "private_mode"{
  type        = bool
  description = "in private mode or not"
  default     = false
}
