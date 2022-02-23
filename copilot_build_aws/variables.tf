variable vpc_cidr {
  type        = string
  description = "VPC in which you want launch Aviatrix Copilot"
  default     = "10.0.0.0/16"
}

variable subnet_cidr {
  type        = string
  description = "Subnet in which you want launch Aviatrix Copilot"
  default     = "10.0.1.0/24"
}

variable use_existing_vpc {
  type        = bool
  description = "Flag to indicate whether to use an existing VPC"
  default     = false
}

variable vpc_id {
  type        = string
  description = "VPC ID, required when use_existing_vpc is true"
  default     = ""
}

variable subnet_id {
  type        = string
  description = "Subnet ID, only required when use_existing_vpc is true"
  default     = ""
}

variable use_existing_keypair {
  type        = bool
  default     = false
  description = "Flag to indicate whether to use an existing key pair"
}

variable keypair {
  type        = string
  description = "Key pair which should be used by Aviatrix Copilot"
}

variable tags {
  type        = map(string)
  description = "Map of common tags which should be used for module resources"
  default     = {}
}

variable type {
  type        = string
  description = "Type of billing, can be 'Copilot' or 'CopilotARM'"
  default     = "Copilot"
}

variable root_volume_size {
  type        = number
  description = "Root volume size for copilot"
  default     = 25

  validation {
    condition     = var.root_volume_size >= 25
    error_message = "The minimum root volume size is 25G."
  }
}

variable root_volume_type {
  type        = string
  description = "Root volume type for copilot"
  default     = "gp2"
}

variable allowed_cidrs {
  type = map(object({
    protocol = string,
    port     = number,
    cidrs    = set(string),
  }))
}

variable instance_type {
  type        = string
  description = "Copilot instance size"
  default     = "t3.2xlarge"
}

variable name_prefix {
  type        = string
  description = "Additional name prefix for your environment resources"
  default     = ""
}

variable copilot_name {
  default     = ""
  type        = string
  description = "Name of copilot that will be launched"
}

variable additional_volumes {
  default = {}
  type = map(object({
    device_name = string,
    volume_id   = string,
  }))
}

data aws_region current {}

data http copilot_iam_id {
  url = "https://aviatrix-download.s3.us-west-2.amazonaws.com/AMI_ID/copilot_ami_id.json"
  request_headers = {
    "Accept" = "application/json"
  }
}

data "aws_availability_zones" "all" {}

data "aws_ec2_instance_type_offering" "offering" {
  for_each = toset(data.aws_availability_zones.all.names)

  filter {
    name   = "instance-type"
    values = ["t3.2xlarge"]
  }

  filter {
    name   = "location"
    values = [each.value]
  }

  location_type = "availability-zone"
}

locals {
  name_prefix       = var.name_prefix != "" ? "${var.name_prefix}-" : ""
  images_copilot    = jsondecode(data.http.copilot_iam_id.body).Copilot
  images_copilotarm = jsondecode(data.http.copilot_iam_id.body).CopilotARM
  ami_id            = var.type == "Copilot" ? local.images_copilot[data.aws_region.current.name] : local.images_copilotarm[data.aws_region.current.name]
  default_az        = keys({ for az, details in data.aws_ec2_instance_type_offering.offering : az => details.instance_type if details.instance_type == "t3.2xlarge" })[0]

  common_tags = merge(
  var.tags, {
    module    = "aviatrix-copilot-aws"
    Createdby = "Terraform+Aviatrix"
  })
}
