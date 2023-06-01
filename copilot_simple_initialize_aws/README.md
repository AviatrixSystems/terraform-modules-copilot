## Aviatrix - Terraform Modules Copilot - AWS Copilot Simple Deployment Initialize

### Description

This Terraform module initializes a newly created Aviatrix Copilot Simple Deployment. This module assumes that the controller and the copilot are all deployed on AWS.

### Example of Launching Initializing Copilot Simple Deployment

``` hcl
module "copilot_build_aws" {
  source                   = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  availability_zone        = "<< copilot availability zone >>"
  keypair                  = "copilot_kp"
  default_data_volume_name = "/dev/sdf"
  controller_public_ip     = "<< controller public ip >>"
  controller_private_ip    = "<< controller private ip >>"
  
  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "tcp"
      port     = "443"
      cidrs = ["<< allowed cidr >>"]
    }
  }
}

module "init" {
  source = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_simple_initialize_aws"
  aws_access_key        = "<< aws access key >>"
  aws_secret_access_key = "<< aws secret access key >>"
  controller_public_ip  = "<< controller public ip >>"
  controller_private_ip = "<< controller private ip >>"
  controller_region     = "<< controller region >>"
  controller_sg_name    = "AviatrixSecurityGroup"
  controller_username   = "<< controller username >>"
  controller_password   = "<< controller password >>"
  copilot_public_ip     = module.copilot_build_aws.public_ip
  copilot_private_ip    = module.copilot_build_aws.private_ip
  copilot_username      = "<< copilot username >>"
  copilot_password      = "<< copilot password >>"
}

output "copilot_private_ip" {
  value = module.copilot_build_aws.private_ip
}

output "copilot_public_ip" {
  value = module.copilot_build_aws.public_ip
}
```

### Variables

> **NOTE:** Valid **controller_public_ip** and **copilot_public_ip** are required when **private_mode** is false.

- **aws_access_key**
  AWS access key.

- **aws_secret_access_key**
  AWS secret access key.

- **controller_public_ip**
  Controller public IP. Default: "0.0.0.0".

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

- **copilot_public_ip**
  Copilot public IP. Default: "0.0.0.0".

- **copilot_private_ip**
  Copilot private IP.

- **copilot_username**
  Copilot username.

- **copilot_password**
  Copilot password.

- **private_mode**
  Flag to indicate whether the copilot is for private mode. Default: false.
