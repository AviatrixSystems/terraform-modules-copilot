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
  description = "Root volume disk size for controller"
  default     = 2000
}

variable root_volume_type {
  type        = string
  description = "Root volume type for controller"
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
  description = "Controller instance size"
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
  description = "Name of controller that will be launched"
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

locals {
  name_prefix       = var.name_prefix != "" ? "${var.name_prefix}-" : ""
  images_copilot    = jsondecode(data.http.copilot_iam_id.body).Copilot
  images_copilotarm = jsondecode(data.http.copilot_iam_id.body).CopilotARM
  ami_id            = var.type == "Copilot" ? local.images_copilot[data.aws_region.current.name] : local.images_copilotarm[data.aws_region.current.name]

  common_tags = merge(
  var.tags, {
    module    = "aviatrix-copilot-aws"
    Createdby = "Terraform+Aviatrix"
  })
}
