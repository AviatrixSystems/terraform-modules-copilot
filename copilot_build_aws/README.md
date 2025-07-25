# Aviatrix Copilot Build AWS

This module builds an Aviatrix Copilot in AWS.

### Usage:

To create an Aviatrix Copilot:

```
provider "aws" {
}

module "copilot_build_aws" {
  source                = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  keypair               = "copilot_kp"
  controller_public_ip  = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "tcp"
      port     = "443"
      cidrs    = ["<< CIDR_1 allowed for HTTPS access >>", "<< CIDR_2 allowed for HTTPS access >>", ...]
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
  
  additional_volumes = {
    "one" = {
      device_name = "<< device name 1 >>"
      volume_id = "<< volume id 1 >>"
    }
    "two" = {
      device_name = "<< device name 2 >>"
      volume_id = "<< volume id 2 >>"
    }
  }
}

output "copilot_private_ip" {
  value = module.copilot_build_aws.private_ip
}

output "copilot_public_ip" {
  value = module.copilot_build_aws.public_ip
}
```

### Variables

- **availability_zone**

  Availability zone for subnet, instance and default data volume. If not set, an availability zone that supports the instance type will be used.

- **vpc_cidr** 

  VPC in which you want launch Aviatrix Copilot. Default: "10.0.0.0/16".

- **subnet_cidr**

  Subnet in which you want launch Aviatrix Copilot. Default: "10.0.1.0/24".

- **use_existing_vpc**

  Flag to indicate whether to use an existing VPC. Default: false.

> **NOTE:** If **use_existing_vpc** is set to true, **vpc_id** and **subnet_id** are required. Make sure the subnet has internet access.

- **vpc_id**

  VPC ID. Only required when use_existing_vpc is true. Default: "".

- **subnet_id**

  Subnet ID. Only required when use_existing_vpc is true. Default: "".

- **use_existing_keypair**

  Flag to indicate whether to use an existing key pair. Default: false.

> **NOTE:** If **use_existing_keypair** is set to false, a key pair with name of **keypair** will be generated. If **use_existing_keypair** is set to true, Copilot will use **keypair** directly.

- **keypair**

  Key pair which should be used by Aviatrix Copilot.

- **tags**

  Map of common tags which should be used for module resources. Default: {}.

- **type**

  Type of billing, can be 'Copilot' or 'CopilotARM'. Default: "Copilot".

- **root_volume_size**

  Root volume size for copilot. The minimum root volume size is 25G. Default: 25.

- **root_volume_type**

  Root volume type for copilot. Default: "gp2".

- **allowed_cidrs**

  Map of allowed incoming CIDRs. Please set protocol(string), port(string) and cidrs(set of strings) in each map element. Please see the example code above for example.

- **instance_type**

  Copilot instance size. Default: "m5.2xlarge" for Copilot and "t4g.2xlarge" for CopilotARM.

- **name_prefix**

  Additional name prefix for your environment resources. Default: "".

- **copilot_name**

  Name of copilot that will be launched. Default: name_prefix + "AviatrixCopilot".

- **default_data_volume_name**

  Name of default data volume. If not set, no default data volume will be created. Default: "".

- **default_data_volume_size**

  Size of default data volume. Default: 50.

- **additional_volumes**

  Map of additional volumes that will be attached to the copilot instance. Please set device_name(string) and volume_id(string) in each map element. Please see the example code above for example.

- **private_mode**

  Flag to indicate whether the copilot is for private mode. Default: false.

> **NOTE:** If **private_mode** is set to true, **use_existing_vpc** is required to be true. Please make sure the private subnet where the copilot instance will be launched has internet access. There will be no public IP for the copilot instance in private mode.

- **is_cluster**

  Flag to indicate whether the copilot is for cluster deployment. Default: false.

- **controller_public_ip**

  Controller public IP. Default: "0.0.0.0".

> **NOTE:** A valid **controller_public_ip** is required when **private_mode** is false.

- **open_ant_topo_service_ports**

  Flag to enable TCP ports 50441-50443 for ANT Topology Service access to CoPilot. Defalt: false.

- **controller_private_ip**

  Controller private IP.

### Outputs

- **ec2-info**

  EC2 instance information.

- **region**

  Current AWS region.

- **vpc_id**

  VPC ID.

- **vpc_name**

  VPC name.

- **public_ip**

  Copilot public IP.

- **private_ip**

  Copilot private IP.
