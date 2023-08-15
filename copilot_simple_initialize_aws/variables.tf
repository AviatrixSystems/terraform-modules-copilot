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

variable "copilot_public_ip" {
  type        = string
  description = "main copilot public IP"
  default     = "0.0.0.0"
}

variable "copilot_private_ip" {
  type        = string
  description = "main copilot private IP"
}

variable "copilot_username" {
  type        = string
  description = "main copilot username"
}

variable "copilot_password" {
  type        = string
  description = "main copilot password"
}

variable "private_mode" {
  type        = bool
  description = "in private mode or not"
  default     = false
}

locals {
  validate_public_ips = (var.private_mode == false && (var.controller_public_ip == "0.0.0.0" || var.copilot_public_ip == "0.0.0.0")) ? tobool("Please pass in valid controller_public_ip and copilot_public_ip when private_mode is false.") : true
}
