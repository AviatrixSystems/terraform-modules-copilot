# Aviatrix Copilot Build AWS

This module builds an Aviatrix Copilot in AWS.

### Usage:

To create an Aviatrix Copilot:

```
provider "aws" {
}

module "copilot_build_aws" {
  source  = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  keypair = "copilot_kp"
  
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

- **vpc_cidr** 

  VPC in which you want launch Aviatrix Copilot. Default: "10.0.0.0/16".

- **subnet_cidr**

  Subnet in which you want launch Aviatrix Copilot. Default: "10.0.1.0/24".

> **NOTE:** If **use_existing_vpc** is set to true, **vpc_id** and **subnet_id** are required. Make sure that resources `aws_vpc`, `aws_internet_gateway`, `aws_route_table`, `aws_route`, `aws_subnet` and `aws_route_table_association` are configured properly.

- **use_existing_vpc**

  Flag to indicate whether to use an existing VPC. Default: false.

- **vpc_id**

  VPC ID. Only required when use_existing_vpc is true. Default: "".

- **subnet_id**

  Subnet ID. Only required when use_existing_vpc is true. Default: "".

> **NOTE:** If **use_existing_keypair** is set to false, a key pair with name of **keypair** will be generated. If **use_existing_keypair** is set to true, Copilot will use **keypair** directly.

- **use_existing_keypair**

  Flag to indicate whether to use an existing key pair. Default: false.

- **keypair**

  Key pair which should be used by Aviatrix Copilot.

- **tags**

  Map of common tags which should be used for module resources. Default: {}.

- **type**

  Type of billing, can be 'Copilot' or 'CopilotARM'. Default: "Copilot".

- **root_volume_size**

  Root volume disk size for controller. Default: 2000.

- **root_volume_type**

  Root volume type for controller. Default: "gp2".

- **allowed_cidrs**

  Map of allowed incoming CIDRs. Please set protocol(string), port(string) and cidrs(set of strings) in each map element. Please see the example code above for example.

- **instance_type**

  Controller instance size. Default: "t3.2xlarge".

- **name_prefix**

  Additional name prefix for your environment resources. Default: "".

- **copilot_name**

  Name of copilot that will be launched. Default: name_prefix + "AviatrixCopilot".

- **additional_volumes**

  Map of additional volumes that will be attached to the copilot instance. Please set device_name(string) and volume_id(string) in each map element. Please see the example code above for example.


### Outputs

- **public_ip**

  Copilot public IP.

- **private_ip**

  Copilot private IP.
