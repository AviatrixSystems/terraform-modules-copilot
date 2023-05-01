variable "availability_zone" {
  type        = string
  description = "Availability zone"
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  description = "VPC in which you want launch Aviatrix Copilot"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet in which you want launch Aviatrix Copilot"
  default     = "10.0.1.0/24"
}

variable "use_existing_vpc" {
  type        = bool
  description = "Flag to indicate whether to use an existing VPC"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID, required when use_existing_vpc is true"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID, only required when use_existing_vpc is true"
  default     = ""
}

variable "use_existing_keypair" {
  type        = bool
  description = "Flag to indicate whether to use an existing key pair"
  default     = false
}

variable "keypair" {
  type        = string
  description = "Key pair which should be used by Aviatrix Copilot"
}

variable "tags" {
  type        = map(string)
  description = "Map of common tags which should be used for module resources"
  default     = {}
}

variable "type" {
  type        = string
  description = "Type of billing, can be 'Copilot' or 'CopilotARM'"
  default     = "Copilot"
}

variable "root_volume_size" {
  type        = number
  description = "Root volume size for copilot"
  default     = 30

  validation {
    condition     = var.root_volume_size >= 30
    error_message = "The minimum root volume size is 30G."
  }
}

variable "root_volume_type" {
  type        = string
  description = "Root volume type for copilot"
  default     = "gp2"
}

variable "allowed_cidrs" {
  type = map(object({
    protocol = string,
    port     = number,
    cidrs    = set(string),
  }))
}

variable "instance_type" {
  type        = string
  description = "Copilot instance size"
  default     = ""
}

variable "name_prefix" {
  type        = string
  description = "Additional name prefix for your environment resources"
  default     = ""
}

variable "copilot_name" {
  default     = ""
  type        = string
  description = "Name of copilot that will be launched"
}

variable "default_data_volume_name" {
  default     = ""
  type        = string
  description = "Name of default data volume. If not set, no default data volume will be created"
}

variable "default_data_volume_size" {
  default     = 50
  type        = number
  description = "Size of default data volume"
}

variable "additional_volumes" {
  default = {}
  type = map(object({
    device_name = string,
    volume_id   = string,
  }))
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

data "aws_region" "current" {}

data "http" "copilot_iam_id" {
  url = "https://aviatrix-download.s3.us-west-2.amazonaws.com/AMI_ID/copilot_ami_id.json"
  request_headers = {
    "Accept" = "application/json"
  }
}

data "aws_availability_zones" "all" {}

data "aws_ec2_instance_type_offering" "offering" {
  for_each = {
    a = "us-east-1"
  }
  
  filter {
    name   = "instance-type"
    values = ["t2.micro", "t3.micro", var.instance_type]
  }

  filter {
    name   = "location"
    values = [each.value]
  }

  location_type = "availability-zone"

  preferred_instance_types = [var.instance_type, "t3.micro", "t2.micro"]
}

locals {
  name_prefix       = var.name_prefix != "" ? "${var.name_prefix}_" : ""
  images_copilot    = jsondecode(data.http.copilot_iam_id.response_body).Copilot
  images_copilotarm = jsondecode(data.http.copilot_iam_id.response_body).CopilotARM
  ami_id            = var.type == "Copilot" ? local.images_copilot[data.aws_region.current.name] : local.images_copilotarm[data.aws_region.current.name]
  instance_type     = var.instance_type != "" ? var.instance_type : (var.type == "Copilot" ? "m5.2xlarge" : "t4g.2xlarge")
  default_az        = keys({ for az, details in data.aws_ec2_instance_type_offering.offering : az => details.instance_type if details.instance_type == local.instance_type })[0]
  availability_zone = var.availability_zone != "" ? var.availability_zone : local.default_az
  controller_ip     = var.private_mode ? var.controller_private_ip : var.controller_public_ip

  common_tags = merge(
    var.tags, {
      module    = "aviatrix-copilot-aws"
      Createdby = "Terraform+Aviatrix"
  })
}
