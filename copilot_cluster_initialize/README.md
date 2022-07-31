## Aviatrix - Terraform Modules Copilot - Copilot Cluster Initialize

### Description

This Terraform module initializes a newly created Aviatrix Copilot Cluster. This module currently only supports AWS.

### Example of Launching Copilot Instances and Initializing the Cluster

>**NOTE:** No matter whether it's in private mode or not, main copilot and nodes **must** be in the same VPC.

**Case 1: Not in private mode**

**In this case, controller and copilot cluster can be in different VPCs.** In the following example:
1. A main copilot instance is launched using the [copilot_build_aws](../copilot_build_aws) module.
2. In the same VPC where the main copilot is, three node copilot instances are launched using the [copilot_build_aws](../copilot_build_aws) module.
3. The copilot cluster is initialized using the [copilot_cluster_initialize](../copilot_cluster_initialize) module.
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

provider "aws" {
  region     = "<< REGION >>"
  access_key = "<< AWS ACCESS KEY >>"
  secret_key = "<< AWS SECRET ACCESS KEY >>"
}

module "main" {
  source                = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  type                  = "Copilot"
  keypair               = "copilot_kp" // "copilot_kp" is an example here
  is_cluster            = true
  controller_public_ip  = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "tcp"
      port     = "443"
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
    "udp_cidrs_1" = {
      protocol = "udp"
      port     = "5000"
      cidrs    = ["0.0.0.0/0"]
    }
    "udp_cidrs_2" = {
      protocol = "udp"
      port     = "31283"
      cidrs    = ["0.0.0.0/0"]
    }
  }
}

// ************
// ** Step 2 **
// ************

data "aws_route_table" "rtb" {
  subnet_id = module.main.ec2-info[0].subnet_id
}

resource "aws_subnet" "node1_subnet" {
  vpc_id     = module.main.vpc_id
  cidr_block = "10.0.2.0/24" // "10.0.2.0/24" is an example here
  
  tags = {
    Name = "node1_subnet"
  }
}

resource "aws_route_table_association" "rta-n1" {
  subnet_id      = aws_subnet.node1_subnet.id
  route_table_id = data.aws_route_table.rtb.id
}

resource "aws_subnet" "node2_subnet" {
  vpc_id     = module.main.vpc_id
  cidr_block = "10.0.3.0/24" // "10.0.3.0/24" is an example here
  
  tags = {
    Name = "node2_subnet"
  }
}

resource "aws_route_table_association" "rta-n2" {
  subnet_id      = aws_subnet.node2_subnet.id
  route_table_id = data.aws_route_table.rtb.id
}

resource "aws_subnet" "node3_subnet" {
  vpc_id     = module.main.vpc_id
  cidr_block = "10.0.4.0/24" // "10.0.4.0/24" is an example here
  
  tags = {
    Name = "node3_subnet"
  }
}

resource "aws_route_table_association" "rta-n3" {
  subnet_id      = aws_subnet.node3_subnet.id
  route_table_id = data.aws_route_table.rtb.id
}

module "node1" {
  source                   = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  use_existing_vpc         = true
  vpc_id                   = module.main.vpc_id
  subnet_id                = aws_subnet.node1_subnet.id
  name_prefix              = "node1"
  use_existing_keypair     = true
  keypair                  = module.main.ec2-info[0].key_name
  default_data_volume_name = "/dev/sdf" // "/dev/sdf" is an example here
  is_cluster               = true
  controller_public_ip     = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip    = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "tcp"
      port     = "443"
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
  }
}

module "node2" {
  source                   = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  use_existing_vpc         = true
  vpc_id                   = module.main.vpc_id
  subnet_id                = aws_subnet.node2_subnet.id
  name_prefix              = "node2"
  use_existing_keypair     = true
  keypair                  = module.main.ec2-info[0].key_name
  default_data_volume_name = "/dev/sdf" // "/dev/sdf" is an example here  
  is_cluster               = true
  controller_public_ip     = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip    = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "tcp"
      port     = "443"
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
  }
}

module "node3" {
  source                   = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  use_existing_vpc         = true
  vpc_id                   = module.main.vpc_id
  subnet_id                = aws_subnet.node3_subnet.id
  name_prefix              = "node3"
  use_existing_keypair     = true
  keypair                  = module.main.ec2-info[0].key_name
  default_data_volume_name = "/dev/sdf" // "/dev/sdf" is an example here  
  is_cluster               = true
  controller_public_ip     = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip    = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "tcp"
      port     = "443"
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
  }
}

// ************
// ** Step 3 **
// ************

module "init" {
  source                    = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_cluster_initialize"
  aws_access_key            = "<< AWS ACCESS KEY >>"
  aws_secret_access_key     = "<< AWS SECRET ACCESS KEY>>"
  controller_public_ip      = "<< CONTROLLER PUBLIC IP >>"
  controller_region         = "<< CONTROLLER REGION >>"
  controller_username       = "<< CONTROLLER USERNAME >>"
  controller_password       = "<< CONTROLLER PASSWORD >>"
  controller_sg_name        = "<< CONTROLLER SG NAME >>"
  main_copilot_public_ip    = module.main.public_ip
  main_copilot_private_ip   = module.main.private_ip
  main_copilot_region       = module.main.region
  main_copilot_username     = "<< CONTROLLER USERNAME >>"
  main_copilot_password     = "<< CONTROLLER PASSWORD >>"
  main_copilot_sg_name      = "AviatrixCopilotSecurityGroup"
  node_copilot_public_ips   = [module.node1.public_ip, module.node2.public_ip, module.node3.public_ip]
  node_copilot_private_ips  = [module.node1.private_ip, module.node2.private_ip, module.node3.private_ip]
  node_copilot_regions      = [module.node1.region, module.node2.region, module.node3.region]
  node_copilot_usernames    = ["<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>"] // please use controller username
  node_copilot_passwords    = ["<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>"] // please use controller password
  node_copilot_data_volumes = ["/dev/sdf", "/dev/sdf", "/dev/sdf"]
  node_copilot_names        = ["node1", "node2", "node3"]
  node_copilot_sg_names     = ["AviatrixCopilotSecurityGroup", "AviatrixCopilotSecurityGroup", "AviatrixCopilotSecurityGroup"]
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

**In this case, controller and copilot cluster must be in the same VPC. Before running the example, subnets for the cluster should be set up. The code must be run on a machine which has access to the internet, the controller and the copilot cluster (main and nodes).** 

In the following example:
1. In the VPC where the controller is, a main copilot instance is launched using the [copilot_build_aws](../copilot_build_aws) module.
2. In the same VPC where the main copilot is, three node copilot instances are launched using the [copilot_build_aws](../copilot_build_aws) module.
3. The copilot cluster is initialized using the [copilot_cluster_initialize](../copilot_cluster_initialize) module.
4. Some settings in the controller are configured using the [Aviatrix Terraform provider](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/2.23.0).

> **NOTE:** 
> 1. After the cluster has been successfully initialized, the following settings need to be configured in the Aviatrix controller. This is the reason for the step 4 above.
> * Enable syslog configuration for main copilot
> * Enable netflow configuration for main copilot
> 2. After deployment, the main copilot ports 31283 and 5000 will be open for any IP (0.0.0.0/0). It is strongly recommended to remove the 0.0.0.0 entry from the CoPilot security group for these ports and add entries for all of your gateway IP addresses.

``` hcl
// ************
// ** Step 1 **
// ************

provider "aws" {
  region     = "<< REGION >>"
  access_key = "<< AWS ACCESS KEY >>"
  secret_key = "<< AWS SECRET ACCESS KEY >>"
}

module "main" {
  source                = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  type                  = "Copilot"
  use_existing_vpc      = true
  vpc_id                = "<< VPC ID >>"
  subnet_id             = "<< SUBNET ID >>"
  keypair               = "copilot_kp" // "copilot_kp" is an example here  
  private_mode          = true
  is_cluster            = true
  controller_private_ip = "<< CONTROLLER PRIVATE IP >>"
    
  allowed_cidrs = {
    "tcp_cidrs_1" = {
      protocol = "tcp"
      port     = "443"
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
    "tcp_cidrs_2" = {
      protocol = "tcp"
      port     = "5000"
      cidrs    = ["0.0.0.0/0"]
    }
    "udp_cidrs_3" = {
      protocol = "tcp"
      port     = "31283"
      cidrs    = ["0.0.0.0/0"]
    }
  }
}

// ************
// ** Step 2 **
// ************

module "node1" {
  source                   = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  use_existing_vpc         = true
  vpc_id                   = "<< VPC ID >>"
  subnet_id                = "<< SUBNET ID >>"
  name_prefix              = "node1"
  use_existing_keypair     = true
  keypair                  = module.main.ec2-info[0].key_name
  default_data_volume_name = "/dev/sdf" // "/dev/sdf" is an example here  
  private_mode             = true
  is_cluster               = true
  controller_private_ip    = "<< CONTROLLER PRIVATE IP >>"
    
  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "tcp"
      port     = "443"
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
  }
}

module "node2" {
  source                   = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  use_existing_vpc         = true
  vpc_id                   = "<< VPC ID >>"
  subnet_id                = "<< SUBNET ID >>"
  name_prefix              = "node2"
  use_existing_keypair     = true
  keypair                  = module.main.ec2-info[0].key_name
  default_data_volume_name = "/dev/sdf" // "/dev/sdf" is an example here  
  private_mode             = true
  is_cluster               = true
  controller_private_ip    = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "tcp"
      port     = "443"
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
  }
}

module "node3" {
  source                   = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  use_existing_vpc         = true
  vpc_id                   = "<< VPC ID >>"
  subnet_id                = "<< SUBNET ID >>"
  name_prefix              = "node3"
  use_existing_keypair     = true
  keypair                  = module.main.ec2-info[0].key_name
  default_data_volume_name = "/dev/sdf" // "/dev/sdf" is an example here  
  private_mode             = true
  is_cluster               = true
  controller_private_ip    = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "tcp"
      port     = "443"
      cidrs    = ["<< CIDRS ALLOWED FOR HTTPS ACCESS >>"] // your current IP must be included
    }
  }
}

// ************
// ** Step 3 **
// ************

module "init" {
  source                    = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_cluster_initialize"
  aws_access_key            = "<< AWS ACCESS KEY >>"
  aws_secret_access_key     = "<< AWS SECRET ACCESS KEY>>"
  controller_private_ip     = "<< CONTROLLER PRIVATE IP >>"  
  controller_region         = "<< CONTROLLER REGION >>"
  controller_username       = "<< CONTROLLER USERNAME >>"
  controller_password       = "<< CONTROLLER PASSWORD >>"
  controller_sg_name        = "<< CONTROLLER SG NAME >>"  
  main_copilot_private_ip   = module.main.private_ip
  main_copilot_region       = module.main.region
  main_copilot_username     = "<< CONTROLLER USERNAME >>"
  main_copilot_password     = "<< CONTROLLER PASSWORD >>"
  main_copilot_sg_name      = "AviatrixCopilotSecurityGroup"  
  node_copilot_private_ips  = [module.node1.private_ip, module.node2.private_ip, module.node3.private_ip]
  node_copilot_regions      = [module.node1.region, module.node2.region, module.node3.region]
  node_copilot_usernames    = ["<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>"]
  node_copilot_passwords    = ["<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>"]
  node_copilot_data_volumes = ["/dev/sdf", "/dev/sdf", "/dev/sdf"]
  node_copilot_names        = ["node1", "node2", "node3"]
  node_copilot_sg_names     = ["AviatrixCopilotSecurityGroup", "AviatrixCopilotSecurityGroup", "AviatrixCopilotSecurityGroup"]
  private_mode              = true
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

- **aws_access_key**
  AWS access key.

- **aws_secret_access_key**
  AWS secret access key.

- **controller_public_ip**
  Controller public IP. Default: "0.0.0.0".

> **NOTE:** A valid **controller_public_ip** is required when **private_mode** is false.

- **controller_private_ip**
  Controller private IP.

- **controller_region**
  controller region.

- **controller_username**
  Controller username.

- **controller_password**
  Controller password.

- **controller_sg_name**
  Controller security group name.

- **main_copilot_public_ip**
  Main copilot public IP. Default: "0.0.0.0".

> **NOTE:** A valid **main_copilot_public_ip** is required when **private_mode** is false.

- **main_copilot_private_ip**
  Main copilot private IP.

- **main_copilot_region**
  Main copilot region.

- **main_copilot_username**
  Main copilot username.

- **main_copilot_password**
  Main copilot password.

- **main_copilot_sg_name**
  Main copilot security group name.

- **node_copilot_public_ips**
  List of node copilot public IPs. Default: ["0.0.0.0"].

> **NOTE:** Valid **node_copilot_public_ips** are required when **private_mode** is false.

- **node_copilot_private_ips**
  List of node copilot private IPs.

- **node_copilot_regions**
  List of node copilot regions.

- **node_copilot_usernames**
  List of node copilot usernames.

- **node_copilot_passwords**
  List of node copilot passwords.

- **node_copilot_data_volumes**
  List of node copilot data volumes.

- **node_copilot_names**
  List of node copilot names.

- **node_copilot_sg_names**
  List of node copilot security group names.

- **private_mode**
  Flag to indicate whether the copilot is for private mode. Default: false.
