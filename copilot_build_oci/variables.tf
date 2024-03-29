variable "tenancy_ocid" {
  type        = string
  description = "Tenancy OCID"
}

variable "compartment_ocid" {
  type        = string
  description = "Compartment OCID"
}

variable "availability_domain_number" {
  type        = number
  description = "Availability domain number"
}

variable "use_existing_vcn" {
  type        = bool
  description = "Flag to indicate whether to use an existing VCN"
  default     = false
}

variable "vcn_id" {
  type        = string
  description = "VCN ID"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
  default     = ""
}

variable "vcn_cidr_block" {
  type        = string
  description = "VCN CIDR"
  default     = "10.1.0.0/16"
}

variable "vcn_display_name" {
  type        = string
  description = "VCN display name"
  default     = "copilot-vcn"
}

variable "vcn_dns_label" {
  type        = string
  description = "VCN DNS label"
  default     = "aviatrix"
}

variable "subnet_cidr_block" {
  type        = string
  description = "Subnet CIDR"
  default     = "10.1.20.0/24"
}

variable "subnet_display_name" {
  type        = string
  description = "Subnet display name"
  default     = "copilot-subnet"
}

variable "subnet_dns_label" {
  type        = string
  description = "Subnet DNS label"
  default     = "management"
}

variable "igw_display_name" {
  type        = string
  description = "IGW display name"
  default     = "copilot-igw"
}

variable "routetable_display_name" {
  type        = string
  description = "Route table display name"
  default     = "copilot-rt"
}

variable "nsg_display_name" {
  type        = string
  description = "NSG display name"
  default     = "copilot-nsg"
}

variable "https_allowed_cidrs" {
  type        = set(string)
  description = "Allowed CIDRs for HTTPS access"
}

variable "udp_allowed_cidrs" {
  type = map(object({
    port = number
    cidr = string,
  }))
  description = "Allowed CIDRs for UDP access"
}

variable "ssh_allowed_cidrs" {
  type        = set(string)
  description = "Allowed CIDRs for SSH access"
  default     = []
}

variable "instance_shape" {
  type        = string
  description = "Instance shape"
  default     = "VM.Standard2.8"
}

variable "boot_volume_size" {
  type        = number
  description = "Boot volume size for copilot"
  default     = 50

  validation {
    condition     = var.boot_volume_size >= 50
    error_message = "The minimum boot volume size is 50G."
  }
}

variable "vm_display_name" {
  type        = string
  description = "VM display name"
  default     = "copilot-vm"
}

variable "copilot_version" {
  type        = string
  description = "Copilot version"
  default     = ""
}

variable "use_existing_ssh_key" {
  type        = bool
  description = "Flag to indicate whether to use an existing ssh key"
  default     = false
}

variable "ssh_public_key_file_path" {
  type        = string
  description = "File path to the SSH public key"
  default     = ""
}

variable "ssh_public_key_file_content" {
  type        = string
  description = "File content of the SSH public key"
  default     = ""
}

variable "default_data_volume_size" {
  default     = 0
  type        = number
  description = "Size of default data disk. If not set, no default data disk will be created."
}

variable "additional_volumes" {
  default = {}
  type = map(object({
    attachment_type = string,
    volume_id       = string,
  }))
}

data "http" "image_info" {
  url = "https://cdn.prod.sre.aviatrix.com/image-details/oci_copilot_image_details.json"

  request_headers = {
    "Accept" = "application/json"
  }
}

locals {
  ssh_key                  = var.use_existing_ssh_key == false ? tls_private_key.key_pair_material[0].public_key_openssh : (var.ssh_public_key_file_path != "" ? file(var.ssh_public_key_file_path) : var.ssh_public_key_file_content)
  listing_resource_version = keys(jsondecode(data.http.image_info.response_body)["BYOL"])[0]
  listing_id               = values(jsondecode(data.http.image_info.response_body)["BYOL"])[0]
}
