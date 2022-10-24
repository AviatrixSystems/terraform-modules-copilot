## Aviatrix - Terraform Modules Copilot - Azure Copilot Cluster Initialize

### Description

This Terraform module initializes a newly created Aviatrix Copilot Cluster. This module assumes that the controller, main copilot and copilot nodes are all deployed on Azure.

### Example of Launching Copilot Instances and Initializing the Cluster

>**NOTE:** No matter whether it's in private mode or not, main copilot and nodes **must** be in the same VNET.

**Case 1: Not in private mode**

**In this case, controller and copilot cluster can be in different VNETs.** In the following example:
1. A main copilot instance is launched using the [copilot_build_azure](../copilot_build_azure) module.
2. In the same VNET where the main copilot is, three node copilot instances are launched using the [copilot_build_azure](../copilot_build_azure) module.
3. The copilot cluster is initialized using the [copilot_cluster_initialize_azure](../copilot_cluster_initialize_azure) module.
4. Some settings in the controller are configured using the [Aviatrix Terraform provider](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/2.23.0).

> **NOTE:** 
> 1. After the cluster has been successfully initialized, the following settings need to be configured in the Aviatrix controller. This is the reason for the step 4 above.
> * Enable syslog configuration for main copilot
> * Enable netflow configuration for main copilot
> * Enable copilot security group management in controller
> 2. After deployment, the main copilot ports 31283 and 5000 will be open for any IP (0.0.0.0/0). It is strongly recommended to remove the 0.0.0.0 entry from the CoPilot security group for these ports and add entries for all of your gateway IP addresses.

``` hcl
// ************
// ** Step 1 **
// ************

provider "azurerm" {
  features {}
  subscription_id = "<< SUBSCRIPTION ID >>"
  client_id       = "<< CLIENT ID >>"
  client_secret   = "<< CLIENT SECRET >>"
  tenant_id       = "<< TENANT ID >>"
}

module "main" {
  source                         = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_azure"
  copilot_name                   = "main"
  virtual_machine_admin_username = "aviatrix"
  default_data_disk_size         = 50
  default_data_disk_name         = "main_data_disk"
  is_cluster                     = true
  controller_public_ip           = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip          = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcp_cidrs" = {
      priority = "100"
      protocol = "Tcp"
      ports    = ["443"]
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
    "udp_cidrs" = {
      priority = "200"
      protocol = "Udp"
      ports    = ["5000", "31283"]
      cidrs    = ["0.0.0.0/0"]
    }
  }
}

// ************
// ** Step 2 **
// ************

resource "azurerm_subnet" "node1_subnet" {
  name                 = "node1-subnet"
  resource_group_name  = module.main.resource_group_name
  virtual_network_name = "main-vnet"
  address_prefixes     = ["10.0.2.0/24"]
  
  depends_on           = [module.main]
}

resource "azurerm_subnet" "node2_subnet" {
  name                 = "node2-subnet"
  resource_group_name  = module.main.resource_group_name
  virtual_network_name = "main-vnet"
  address_prefixes     = ["10.0.3.0/24"]
  
  depends_on           = [module.main]
}

resource "azurerm_subnet" "node3_subnet" {
  name                 = "node3-subnet"
  resource_group_name  = module.main.resource_group_name
  virtual_network_name = "main-vnet"
  address_prefixes     = ["10.0.4.0/24"]
  
  depends_on           = [module.main]
}

module "node1" {
  source                         = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_azure"
  use_existing_vnet              = true
  resource_group_name            = module.main.resource_group_name
  subnet_id                      = azurerm_subnet.node1_subnet.id
  copilot_name                   = "node1"
  virtual_machine_admin_username = "aviatrix"
  default_data_disk_size         = 50
  default_data_disk_name         = "node1_data_disk"
  is_cluster                     = true
  controller_public_ip           = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip          = "<< CONTROLLER PRIVATE IP >>"

  allowed_cidrs = {
    "tcp_cidrs" = {
      priority = "100"
      protocol = "Tcp"
      ports    = ["443"]
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
    "udp_cidrs" = {
      priority = "200"
      protocol = "Udp"
      ports    = ["5000", "31283"]
      cidrs    = ["0.0.0.0/0"]
    }
  }

  depends_on = [module.main]
}

module "node2" {
  source                         = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_azure"
  use_existing_vnet              = true
  resource_group_name            = module.main.resource_group_name
  subnet_id                      = azurerm_subnet.node2_subnet.id
  copilot_name                   = "node2"
  virtual_machine_admin_username = "aviatrix"
  default_data_disk_size         = 50
  default_data_disk_name         = "node2_data_disk"
  is_cluster                     = true
  controller_public_ip           = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip          = "<< CONTROLLER PRIVATE IP >>"

  allowed_cidrs = {
    "tcp_cidrs" = {
      priority = "100"
      protocol = "Tcp"
      ports    = ["443"]
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
    "udp_cidrs" = {
      priority = "200"
      protocol = "Udp"
      ports    = ["5000", "31283"]
      cidrs    = ["0.0.0.0/0"]
    }
  }

  depends_on = [module.main]
}

module "node3" {
  source                         = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_azure"
  use_existing_vnet              = true
  resource_group_name            = module.main.resource_group_name
  subnet_id                      = azurerm_subnet.node3_subnet.id
  copilot_name                   = "node3"
  virtual_machine_admin_username = "aviatrix"
  default_data_disk_size         = 50
  default_data_disk_name         = "node3_data_disk"
  is_cluster                     = true
  controller_public_ip           = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip          = "<< CONTROLLER PRIVATE IP >>"

  allowed_cidrs = {
    "tcp_cidrs" = {
      priority = "100"
      protocol = "Tcp"
      ports    = ["443"]
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
    "udp_cidrs" = {
      priority = "200"
      protocol = "Udp"
      ports    = ["5000", "31283"]
      cidrs    = ["0.0.0.0/0"]
    }
  }

  depends_on = [module.main]
}

// ************
// ** Step 3 **
// ************

module "init" {
  source                                    = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_cluster_initialize_azure"
  subscription_id                           = "<< SUBSCRIPTION ID >>"
  client_id                                 = "<< CLIENT ID >>"
  client_secret                             = "<< CLIENT SECRET >>"
  tenant_id                                 = "<< TENANT ID >>"
  controller_public_ip                      = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip                     = "<< CONTROLLER PRIVATE IP >>"
  controller_username                       = "<< CONTROLLER USERNAME >>"
  controller_password                       = "<< CONTROLLER PASSWORD >>"
  controller_resource_group_name            = "<< CONTROLLER RESOURCE GROUP NAME >>"
  controller_network_security_group_name    = "<< CONTROLLER NETWORK SECURITY GROUP NAME >>"
  controller_security_rule_name             = "<< CONTROLLER SECURITY RULE NAME >>"
  controller_security_rule_priority         = 1000
  copilot_cluster_resource_group_name       = module.main.resource_group_name
  main_copilot_public_ip                    = module.main.public_ip
  main_copilot_private_ip                   = module.main.private_ip
  main_copilot_username                     = "<< CONTROLLER USERNAME >>"
  main_copilot_password                     = "<< CONTROLLER PASSWORD >>"
  main_copilot_network_security_group_name  = module.main.network_security_group_name
  main_copilot_security_rule_name           = "main-copilot-cluster-rule"
  main_copilot_security_rule_priority       = 1000
  node_copilot_public_ips                   = [module.node1.public_ip, module.node2.public_ip, module.node3.public_ip]
  node_copilot_private_ips                  = [module.node1.private_ip, module.node2.private_ip, module.node3.private_ip]
  node_copilot_usernames                    = ["<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>"]
  node_copilot_passwords                    = ["<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>"]
  node_copilot_names                        = ["node1", "node2", "node3"]
  node_copilot_network_security_group_names = [module.node1.network_security_group_name, module.node2.network_security_group_name, module.node3.network_security_group_name]
  node_copilot_security_rule_names          = ["node1-copilot-cluster-rule", "node2-copilot-cluster-rule", "node3-copilot-cluster-rule"]
  node_copilot_security_rule_priorities     = [1000, 1000, 1000]

  depends_on = [module.main, module.node1, module.node2, module.node3]
}

output "main_public_ip" {
  value = module.main.public_ip
}
output "main_private_ip" {
  value = module.main.private_ip
}
output "node1_public_ip" {
  value = module.node1.public_ip
}
output "node1_private_ip" {
  value = module.node1.private_ip
}
output "node2_public_ip" {
  value = module.node2.public_ip
}
output "node2_private_ip" {
  value = module.node2.private_ip
}
output "node3_public_ip" {
  value = module.node3.public_ip
}
output "node3_private_ip" {
  value = module.node3.private_ip
}

// ************
// ** Step 4 **
// ************

terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "2.23.0" // version 2.23+ is required
    }
  }
}

provider "aviatrix" {
  username      = "<< CONTROLLER USERNAME >>"
  password      = "<< CONTROLLER PASSWORD >>"
  controller_ip = "<< CONTROLLER PUBLIC IP >>"
}

resource "aviatrix_remote_syslog" "copilot_remote_syslog" {
  index    = 9
  name     = "example"
  server   = module.main.public_ip
  port     = 5000
  protocol = "UDP"
}

resource "aviatrix_netflow_agent" "copilot_netflow_agent" {
  server_ip = module.main.public_ip
  port      = 31283
}

resource "aviatrix_copilot_security_group_management_config" "copilot_sg_mgmt" {
  cloud_type                               = 1
  account_name                             = "<< ACCESS ACCOUNT NAME >>"
  region                                   = module.main.region
  vpc_id                                   = module.main.vpc_id
  instance_id                              = module.main.ec2-info[0].id
  enable_copilot_security_group_management = true
}
```

**Case 2: In private mode**

**In this case, controller and copilot cluster must be in the same VNET. Before running the example, subnets for the cluster should be set up. The code must be run on a machine which has access to the internet, the controller and the copilot cluster (main and nodes).** 

In the following example:
1. In the VNET where the controller is, a main copilot instance is launched using the [copilot_build_azure](../copilot_build_azure) module.
2. In the same VNET where the main copilot is, three node copilot instances are launched using the [copilot_build_azure](../copilot_build_azure) module.
3. The copilot cluster is initialized using the [copilot_cluster_initialize_azure](../copilot_cluster_initialize_azure) module.
4. Some settings in the controller are configured using the [Aviatrix Terraform provider](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/2.23.0).

> **NOTE:** 
> 1. After the cluster has been successfully initialized, the following settings need to be configured in the Aviatrix controller. This is the reason for the step 4 above.
> * Enable syslog configuration for main copilot
> * Enable netflow configuration for main copilot
> 2. After deployment, the main copilot ports 31283 and 5000 will be open for any IP (0.0.0.0/0). It is strongly recommended removing the 0.0.0.0 entry from the CoPilot security group for these ports and add entries for all of your gateway IP addresses.

``` hcl
// ************
// ** Step 1 **
// ************

provider "azurerm" {
  features {}
  subscription_id = "<< SUBSCRIPTION ID >>"
  client_id       = "<< CLIENT ID >>"
  client_secret   = "<< CLIENT SECRET >>"
  tenant_id       = "<< TENANT ID >>"
}

module "main" {
  source                         = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_azure"
  copilot_name                   = "main"
  virtual_machine_admin_username = "aviatrix"
  default_data_disk_size         = 50
  default_data_disk_name         = "main_data_disk"
  private_mode                   = true
  is_cluster                     = true
  controller_public_ip           = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip          = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcp_cidrs" = {
      priority = "100"
      protocol = "Tcp"
      ports    = ["443"]
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
    "udp_cidrs" = {
      priority = "200"
      protocol = "Udp"
      ports    = ["5000", "31283"]
      cidrs    = ["0.0.0.0/0"]
    }
  }
}

// ************
// ** Step 2 **
// ************

module "node1" {
  source                         = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_azure"
  use_existing_vnet              = true
  resource_group_name            = module.main.resource_group_name
  subnet_id                      = azurerm_subnet.node1_subnet.id
  copilot_name                   = "node1"
  virtual_machine_admin_username = "aviatrix"
  default_data_disk_size         = 50
  default_data_disk_name         = "node1_data_disk"
  private_mode                   = true
  is_cluster                     = true
  controller_public_ip           = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip          = "<< CONTROLLER PRIVATE IP >>"

  allowed_cidrs = {
    "tcp_cidrs" = {
      priority = "100"
      protocol = "Tcp"
      ports    = ["443"]
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
    "udp_cidrs" = {
      priority = "200"
      protocol = "Udp"
      ports    = ["5000", "31283"]
      cidrs    = ["0.0.0.0/0"]
    }
  }

  depends_on = [module.main]
}

module "node2" {
  source                         = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_azure"
  use_existing_vnet              = true
  resource_group_name            = module.main.resource_group_name
  subnet_id                      = azurerm_subnet.node2_subnet.id
  copilot_name                   = "node2"
  virtual_machine_admin_username = "aviatrix"
  default_data_disk_size         = 50
  default_data_disk_name         = "node2_data_disk"
  private_mode                   = true  
  is_cluster                     = true
  controller_public_ip           = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip          = "<< CONTROLLER PRIVATE IP >>"

  allowed_cidrs = {
    "tcp_cidrs" = {
      priority = "100"
      protocol = "Tcp"
      ports    = ["443"]
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
    "udp_cidrs" = {
      priority = "200"
      protocol = "Udp"
      ports    = ["5000", "31283"]
      cidrs    = ["0.0.0.0/0"]
    }
  }

  depends_on = [module.main]
}

module "node3" {
  source                         = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_azure"
  use_existing_vnet              = true
  resource_group_name            = module.main.resource_group_name
  subnet_id                      = azurerm_subnet.node3_subnet.id
  copilot_name                   = "node3"
  virtual_machine_admin_username = "aviatrix"
  default_data_disk_size         = 50
  default_data_disk_name         = "node3_data_disk"
  private_mode                   = true
  is_cluster                     = true
  controller_public_ip           = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip          = "<< CONTROLLER PRIVATE IP >>"

  allowed_cidrs = {
    "tcp_cidrs" = {
      priority = "100"
      protocol = "Tcp"
      ports    = ["443"]
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
    "udp_cidrs" = {
      priority = "200"
      protocol = "Udp"
      ports    = ["5000", "31283"]
      cidrs    = ["0.0.0.0/0"]
    }
  }

  depends_on = [module.main]
}

// ************
// ** Step 3 **
// ************

module "init" {
  source                                    = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_cluster_initialize_azure"
  subscription_id                           = "<< SUBSCRIPTION ID >>"
  client_id                                 = "<< CLIENT ID >>"
  client_secret                             = "<< CLIENT SECRET >>"
  tenant_id                                 = "<< TENANT ID >>"
  controller_private_ip                     = "<< CONTROLLER PRIVATE IP >>"
  controller_username                       = "<< CONTROLLER USERNAME >>"
  controller_password                       = "<< CONTROLLER PASSWORD >>"
  controller_resource_group_name            = "<< CONTROLLER RESOURCE GROUP NAME >>"
  controller_network_security_group_name    = "<< CONTROLLER NETWORK SECURITY GROUP NAME >>"
  controller_security_rule_name             = "<< CONTROLLER SECURITY RULE NAME >>"
  controller_security_rule_priority         = 1000
  copilot_cluster_resource_group_name       = module.main.resource_group_name
  main_copilot_private_ip                   = module.main.private_ip
  main_copilot_username                     = "<< CONTROLLER USERNAME >>"
  main_copilot_password                     = "<< CONTROLLER PASSWORD >>"
  main_copilot_network_security_group_name  = module.main.network_security_group_name
  main_copilot_security_rule_name           = "<< MAIN COPILOT SECURITY RULE NAME >>"
  main_copilot_security_rule_priority       = 1000
  node_copilot_private_ips                  = [module.node1.private_ip, module.node2.private_ip, module.node3.private_ip]
  node_copilot_usernames                    = ["<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>"]
  node_copilot_passwords                    = ["<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>"]
  node_copilot_names                        = ["node1", "node2", "node3"]
  node_copilot_network_security_group_names = [module.node1.network_security_group_name, module.node2.network_security_group_name, module.node3.network_security_group_name]
  node_copilot_security_rule_names          = ["<< NODE1 SECURITY RULE NAME >>", "<< NODE2 SECURITY RULE NAME >>", "<< NODE3 SECURITY RULE NAME >>"]
  node_copilot_security_rule_priorities     = [1000, 1000, 1000]
  private_mode                              = true
  
  depends_on = [module.main, module.node1, module.node2, module.node3]
}

output "main_private_ip" {
  value = module.main.private_ip
}

output "node1_private_ip" {
  value = module.node1.private_ip
}

output "node2_private_ip" {
  value = module.node2.private_ip
}

output "node3_private_ip" {
  value = module.node3.private_ip
}

// ************
// ** Step 4 **
// ************

terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      version = "2.23.0" // version 2.23+ is required
    }
  }
}

provider "aviatrix" {
  username      = "<< CONTROLLER USERNAME >>"
  password      = "<< CONTROLLER PASSWORD >>"
  controller_ip = "<< CONTROLLER PUBLIC IP >>"
}

resource "aviatrix_remote_syslog" "copilot_remote_syslog" {
  index    = 9
  name     = "example"
  server   = module.main.public_ip
  port     = 5000
  protocol = "TCP"
}

resource "aviatrix_netflow_agent" "copilot_netflow_agent" {
  server_ip = module.main.public_ip
  port      = 31283
}
```

### Variables

- **subscription_id**
  Subscription ID.

- **client_id**
  Client ID.

- **client_secret**
  Client secret.

- **tenant_id**
  Tenant ID.

- **controller_public_ip**
  Controller public IP. Default: "0.0.0.0".

> **NOTE:** A valid **controller_public_ip** is required when **private_mode** is false.

- **controller_private_ip**
  Controller private IP.

- **controller_username**
  Controller username.

- **controller_password**
  Controller password.

- **controller_resource_group_name**
  Controller resource group name.

- **controller_network_security_group_name**
  Controller network security group name.

- **controller_security_rule_name**
  Controller security rule name.

- **controller_security_rule_priority**
  Controller security rule priority.

- **copilot_cluster_resource_group_name**
  Copilot cluster resource group name.

- **main_copilot_public_ip**
  Main copilot public IP. Default: "0.0.0.0".

> **NOTE:** A valid **main_copilot_public_ip** is required when **private_mode** is false.

- **main_copilot_private_ip**
  Main copilot private IP.

- **main_copilot_username**
  Main copilot username.

- **main_copilot_password**
  Main copilot password.

- **main_copilot_network_security_group_name**
  Main copilot network security group name.

- **main_copilot_security_rule_name**
  Main copilot security rule name.

- **main_copilot_security_rule_priority**
  Main copilot security rule priority.

- **node_copilot_public_ips**
  List of node copilot public IPs. Default: ["0.0.0.0"].

> **NOTE:** Valid **node_copilot_public_ips** are required when **private_mode** is false.

- **node_copilot_private_ips**
  List of node copilot private IPs.

- **node_copilot_usernames**
  List of node copilot usernames.

- **node_copilot_passwords**
  List of node copilot passwords.

- **node_copilot_names**
  List of node copilot names.

- **node_copilot_network_security_group_names**
  List of node copilot network security group names.

- **node_copilot_security_rule_names**
  List of node copilot security rule names.

- **node_copilot_security_rule_priorities**
  List of node copilot security rule priorities.

- **private_mode**
  Flag to indicate whether the copilot is for private mode. Default: false.
