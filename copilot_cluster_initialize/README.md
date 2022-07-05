## Aviatrix - Terraform Modules Copilot - Copilot Cluster Initialize

### Description

This Terraform module initializes a newly created Aviatrix Copilot Cluster. This module currently only supports AWS.

### Basic Usage

``` hcl
module "copilot_cluster_initialize" {
  source                    = "github.com/AviatrixSystems/terraform-module-copilot.git//copilot_cluster_initialize"
  aws_access_key            = "<< AWS access key >>"
  aws_secret_access_key     = "<< AWS secret access key >>"
  controller_public_ip      = "<< controller public IP >>"
  controller_region         = "<< controller region >>"
  controller_username       = "<< controller username >>"
  controller_password       = "<< controller password >>"
  main_copilot_public_ip    = "<< main copilot public IP >>"
  main_copilot_private_ip   = "<< main copilot private IP >>"
  main_copilot_region       = "<< main copilot region >>"
  main_copilot_username     = "<< main copilot username >>"
  main_copilot_password     = "<< main copilot password >>"
  node_copilot_public_ips   = ["<< node1 public IP >>", "<< node2 public IP >>", "<< node3 public IP >>", ...]
  node_copilot_private_ips  = ["<< node1 private IP >>", "<< node2 private IP >>", "<< node3 private IP >>", ...]
  node_copilot_regions      = ["<< node1 region >>", "<< node2 region >>", "<< node3 region >>", ...]
  node_copilot_usernames    = ["<< node1 username >>", "<< node2 username >>", "<< node3 username >>", ...]
  node_copilot_passwords    = ["<< node1 password >>", "<< node2 password >>", "<< node3 password >>", ...]
  node_copilot_data_volumes = ["<< node1 data volume >>", "<< node2 data volume >>", "<< node3 data volume >>", ...]
  node_copilot_names        = ["<< node1 name>>", "<< node2 name >>", "<< node3 name >>", ...]
}
```

### Example of Launching Copilot Instances and Initializing the Cluster

In the following example:
1. A main copilot instance is launched using the [copilot_build_aws](../copilot_build_aws) module.
2. In the same VPC where the main copilot is, three node copilot instances are launched using the [copilot_build_aws](../copilot_build_aws) module.
3. The copilot cluster is initialized using the [copilot_cluster_initialize](../copilot_cluster_initialize) module.
4. Some settings in the controller are configured using the [Aviatrix Terraform provider](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/2.23.0). 

> **NOTE:** After the cluster has been successfully initialized, the following settings need to be configured in the Aviatrix controller. This is the reason for the step 4 above.
> * Enable Syslog configuration for main CoPilot
> * Enable Netflow configuration for main CoPilot
> * Enable CoPilot security group management

``` hcl
// ************
// ** Step 1 **
// ************

provider "aws" {
  region = "<< REGION >>"
  access_key = "<< AWS ACCESS KEY >>"
  secret_key = "<< AWS SECRET ACCESS KEY >>"
}

module "main" {
  source = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  type = "Copilot"
  allowed_cidrs = {
    "udp_cidrs_1" = {
      protocol = "udp"
      port = "5000"
      cidrs = ["<< CONTROLLER IP >>"]
    }
    "udp_cidrs_2" = {
      protocol = "udp"
      port = "31283"
      cidrs = ["<< CONTROLLER IP >>"]
    }
  }
  keypair = "copilot_kp" // "copilot_kp" is an example here
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
  subnet_id = aws_subnet.node1_subnet.id
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
  subnet_id = aws_subnet.node2_subnet.id
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
  subnet_id = aws_subnet.node3_subnet.id
  route_table_id = data.aws_route_table.rtb.id
}

module "node1" {
  source = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  use_existing_vpc = true
  vpc_id = module.main.vpc_id
  subnet_id = aws_subnet.node1_subnet.id
  name_prefix = "node1"
  allowed_cidrs = {
      "udp_cidrs_1" = {
        protocol = "udp"
        port = "5000"
        cidrs = ["<< CONTROLLER IP >>"]
      }
      "udp_cidrs_2" = {
        protocol = "udp"
        port = "31283"
        cidrs = ["<< CONTROLLER IP >>"]
      }
    }
  use_existing_keypair = true
  keypair = "copilot_kp"
  default_data_volume_name = "/dev/sdf" // "/dev/sdf" is an example here
}

module "node2" {
  source = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  use_existing_vpc = true
  vpc_id = module.main.vpc_id
  subnet_id = aws_subnet.node2_subnet.id
  name_prefix = "node2"
  allowed_cidrs = {
    "udp_cidrs_1" = {
      protocol = "udp"
      port = "5000"
      cidrs = ["<< CONTROLLER IP >>"]
    }
    "udp_cidrs_2" = {
      protocol = "udp"
      port = "31283"
      cidrs = ["<< CONTROLLER IP >>"]
    }
  }
  use_existing_keypair = true
  keypair = "copilot_kp"
  default_data_volume_name = "/dev/sdf" // "/dev/sdf" is an example here
}

module "node3" {
  source = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  use_existing_vpc = true
  vpc_id = module.main.vpc_id
  subnet_id = aws_subnet.node3_subnet.id
  name_prefix = "node3"
  allowed_cidrs = {
    "udp_cidrs_1" = {
      protocol = "udp"
      port = "5000"
      cidrs = ["<< CONTROLLER IP >>"]
    }
    "udp_cidrs_2" = {
      protocol = "udp"
      port = "31283"
      cidrs = ["<< CONTROLLER IP >>"]
    }
  }
  use_existing_keypair = true
  keypair = "copilot_kp"
  default_data_volume_name = "/dev/sdf" // "/dev/sdf" is an example here
}

// ************
// ** Step 3 **
// ************

module "init" {
  source = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_cluster_initialize"
  aws_access_key = "<< AWS ACCESS KEY >>"
  aws_secret_access_key = "<< AWS SECRET ACCESS KEY>>"
  controller_public_ip = "<< CONTROLLER PUBLIC IP >>"
  controller_region = "<< CONTROLLER REGION >>"
  controller_username = "<< CONTROLLER USERNAME >>"
  controller_password = "<< CONTROLLER PASSWORD >>"
  main_copilot_public_ip = module.main.public_ip
  main_copilot_private_ip = module.main.private_ip
  main_copilot_region = module.main.region
  main_copilot_username = "<< CONTROLLER USERNAME >>"
  main_copilot_password = "<< CONTROLLER PASSWORD >>"
  node_copilot_public_ips = [module.node1.public_ip, module.node2.public_ip, module.node3.public_ip]
  node_copilot_private_ips = [module.node1.private_ip, module.node2.private_ip, module.node3.private_ip]
  node_copilot_regions = [module.node1.region, module.node2.region, module.node3.region]
  node_copilot_usernames = ["<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>"]
  node_copilot_passwords = ["<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>"]
  node_copilot_data_volumes = ["/dev/sdf", "/dev/sdf", "/dev/sdf"]
  node_copilot_names = ["node1", "node2", "node3"]
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
  username = "<< CONTROLLER USERNAME >>"
  password = "<< CONTROLLER PASSWORD >>"
  controller_ip = "<< CONTROLLER PUBLIC IP >>"
}

resource "aviatrix_remote_syslog" "copilot_remote_syslog" {
  index = 5 // "5" is an example here
  name = "example"
  server = module.main.public_ip
  port = 5000
  protocol = "UDP" // use "TCP" for private mode
}

resource "aviatrix_netflow_agent" "copilot_netflow_agent" {
  server_ip = module.main.public_ip
  port = 31283
}

resource "aviatrix_copilot_security_group_management_config" "copilot_sg_mgmt" {
  cloud_type = 1
  account_name = "<< ACCESS ACCOUNT NAME >>"
  region = module.main.region
  vpc_id = module.main.vpc_id
  instance_id = module.main.ec2-info[0].id
  enable_copilot_security_group_management = true
}
```

### Variables

- **aws_access_key** 
  AWS access key.

- **aws_secret_access_key**
  AWS secret access key.

- **controller_public_ip**
  Controller public IP.

- **controller_region**
  controller region.

- **controller_username**
  Controller username.

- **controller_password**
  Controller password.

- **main_copilot_public_ip**
  Main copilot public IP.

- **main_copilot_private_ip**
  Main copilot private IP.

- **main_copilot_region**
  Main copilot region.

- **main_copilot_username**
  Main copilot username.

- **main_copilot_password**
  Main copilot password.

- **node_copilot_public_ips**
  List of node copilot public IPs.

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
