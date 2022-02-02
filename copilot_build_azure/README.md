# Aviatrix Copilot Build Azure

This module builds an Aviatrix Copilot in Azure.

### Usage:

To create an Aviatrix Copilot:

```
provider "azurerm" {
  features {}
}

module "copilot_build_azure" {
  source                         = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_azure"
  copilot_name                   = "<< copilot name >>"
  virtual_machine_admin_username = "<< username >>"
  virtual_machine_admin_password = "<< password >>"
  
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
  
  additional_disks = {
    "one" = {
      managed_disk_id = "<< managed disk id 1 >>"
      lun = "<< logic unit number 1 >>"
    }
    "two" = {
      managed_disk_id = "<< managed disk id 2 >>"
      lun = "<< logic unit number 2 >>"
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

- **vnet_cidr**
  
  CIDR for Copilot VNET. Default: "10.0.0.0/24".

- **subnet_cidr**
  
  CIDR for copilot subnet. Default: "10.0.0.0/24".

> **NOTE:** If **use_existing_vnet** is set to true, **resource_group_name** and **subnet_id** are required. Make sure that resources `azurerm_resource_group`, `azurerm_virtual_network` and `azurerm_subnet` are configured properly.

- **use_existing_vnet**

  Flag to indicate whether to use an existing vnet. Default: false.

- **resource_group_name**

  Resource group name. Only required when use_existing_vnet is true. Default: "".

- **subnet_id**

  Subnet ID. Only required when use_existing_vnet is true. Default: "".

- **virtual_machine_admin_username**

  Admin Username for the copilot virtual machine.

- **virtual_machine_admin_password**

  Admin Password for the copilot virtual machine.

- **virtual_machine_size**

  Virtual Machine size for the copilot. Default: "Standard_A4_v2".

- **allowed_cidrs**

  Map of allowed incoming CIDRs. Please set priority(string), protocol(string), ports(set of strings) and cidrs(set of strings) in each map element. Please see the example code above for example.

- **os_disk_name**

  OS disk name of the copilot virtual machine. By default, a random name will be generated.

- **additional_disks**

  Map of additional disks that will be attached to the copilot vm. Please set managed_disk_id(string) and lun(string) in each map element. Please see the example code above for example.

### Outputs

- **public_ip**

  Copilot public IP.

- **private_ip**

  Copilot private IP.
