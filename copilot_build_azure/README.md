# Aviatrix Copilot Build Azure

This module builds an Aviatrix Copilot in Azure.

### Usage:

To create an Aviatrix Copilot:

```
provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
}

module "copilot_build_azure" {
  source             = "git@github.com:AviatrixSystems/terraform-modules-copilot/copilot_build_azure.git"
  copilot_name       = "<< copilot name >>"
  incoming_ssl_cidrs = ["<< CIDR_1 allowed for HTTPS access >>", "<< CIDR_2 allowed for HTTPS access >>", ...]
  allowed_cidrs = {
    "tcp_cidrs" = {
      priority = "100"
      protocol = "tcp"
      ports    = ["443"]
      cidrs    = ["<< CIDR_1 >>", "<< CIDR_2 >>", ...]
    }
    "udp_cidrs" = {
      priority = "200"
      protocol = "udp"
      ports    = ["5000", "31283"]
      cidrs    = ["<< CIDR_1 >>", "<< CIDR_2 >>", ...]
    }
  }
}

output "copilot_public_ip" {
  value = module.copilot_build_azure.public_ip
}

output "copilot_private_ip" {
  value = module.copilot_build_azure.private_ip
}
```

### Variables

- **location**
  
  Resource Group Location for Aviatrix Copilot. Default: "West US".

- **copilot_name**
  
  Customized Name for Aviatrix Copilot.

- **copilot_vnet_cidr**
  
  CIDR for Copilot VNET. Default: "10.0.0.0/24".

- **copilot_subnet_cidr**
  
  CIDR for copilot subnet. Default: "10.0.0.0/24".

- **copilot_virtual_machine_admin_username**

  Admin Username for the copilot virtual machine. Default: "aviatrix".

- **copilot_virtual_machine_admin_password**

  Admin Password for the copilot virtual machine. Default: "aviatrix1234!".

- **copilot_virtual_machine_size**

  Virtual Machine size for the copilot. Default: "Standard_A4_v2".

- **allowed_cidrs**

  Map of allowed incoming CIDRs. Please set priority(string), protocol(string), ports(set of strings) and cidrs(set of strings) in each map element. Please see the example code above for example.

### Outputs

- **aviatrix_copilot_public_ip**

  Copilot public IP.

- **aviatrix_copilot_private_ip**

  Copilot private IP.
