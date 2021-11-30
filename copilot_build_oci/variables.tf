variable "tenancy_ocid" {
  type = string
  description = "Tenancy OCID"
}

variable "compartment_ocid" {
  type = string
  description = "Compartment OCID"
}

variable "availability_domain_number" {
  type = number
  description = "Availability domain number"
}

variable "use_existing_vcn" {
  type = bool
  description = "Flag to indicate whether to use an existing VCN"
  default = false
}

variable "vcn_id" {
  type = string
  description = "VCN ID"
  default = ""
}

variable "subnet_id" {
  type = string
  description = "Subnet ID"
  default = ""
}

variable "vcn_cidr_block" {
  type = string
  description = "VCN CIDR"
  default = "10.1.0.0/16"
}

variable "vcn_display_name" {
  type = string
  description = "VCN display name"
  default = "copilot-vcn"
}

variable "vcn_dns_label" {
  type = string
  description = "VCN DNS label"
  default = "aviatrix"
}

variable "subnet_cidr_block" {
  type = string
  description = "Subnet CIDR"
  default = "10.1.20.0/24"
}

variable "subnet_display_name" {
  type = string
  description = "Subnet display name"
  default = "copilot-subnet"
}

variable "subnet_dns_label" {
  type = string
  description = "Subnet DNS label"
  default = "management"
}

variable "igw_display_name" {
  type = string
  description = "IGW display name"
  default = "copilot-igw"
}

variable "routetable_display_name" {
  type = string
  description = "Route table display name"
  default = "copilot-rt"
}

variable "nsg_display_name" {
  type = string
  description = "NSG display name"
  default = "copilot-nsg"
}

variable "tcp_allowed_cidrs" {
  type = set(string)
  description = "Allowed CIDRs for TCP access"
}

variable "udp_allowed_cidrs" {
  type = map(object({
    port     = number
    cidr     = string,
  }))
  description = "Allowed CIDRs for UDP access"
}

variable "instance_shape" {
  type = string
  description = "Instance shape"
  default = "VM.Standard2.8"
}

variable "vm_display_name" {
  type = string
  description = "VM display name"
  default = "copilot-vm"
}
