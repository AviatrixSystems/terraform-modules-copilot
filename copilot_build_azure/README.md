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

- **incoming_ssl_cidrs**

  Incoming CIDRs allowed for HTTPS access.

### Outputs

- **aviatrix_copilot_public_ip**

  Copilot public IP.

- **aviatrix_copilot_private_ip**

  Copilot private IP.
