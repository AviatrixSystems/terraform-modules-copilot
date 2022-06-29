## Aviatrix - Terraform Modules Copilot - Copilot Cluster Initialize

### Description

This Terraform module initializes a newly created Aviatrix Copilot Cluster. This module currently only supports AWS.

### Usage

``` terraform
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
