variable "tenancy_ocid" {}

variable "compartment_ocid" {}

variable "vcn_cidr_block" {
  default = "10.1.0.0/16"
}

variable "vcn_display_name" {
  default = "copilot-vcn"
}

variable "vcn_dns_label" {
  default = "aviatrix"
}

variable "subnet_cidr_block" {
  default = "10.1.20.0/24"
}

variable "subnet_display_name" {
  default = "copilot-subnet"
}

variable "subnet_dns_label" {
  default = "management"
}

variable "igw_display_name" {
  default = "copilot-igw"
}

variable "routetable_display_name" {
  default = "copilot-rt"
}

variable "nsg_display_name" {
  default = "copilot-nsg"
}

variable "tcp_allowed_cidrs" {
  type = set(string)
}

variable "udp_allowed_cidrs" {
  type = map(object({
    port     = number
    cidr     = string,
  }))
}

variable "instance_shape" {
  default = "VM.Standard2.8"
}

variable "vm_display_name" {
  default = "copilot-vm"
}
