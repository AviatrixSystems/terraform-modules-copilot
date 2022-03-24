# Aviatrix Copilot Build GCP

This module builds an Aviatrix Copilot in GCP.

### Usage:

To create an Aviatrix Copilot:

```
provider "google" {
}

module "copilot_build_gcp" {
  source       = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_gcp"
  copilot_name = "copilot"
  allowed_cidrs = {
    "tcp" = {
      protocol = "tcp"
      port     = "443"
      cidrs    = ["<< CIDR_1 allowed for HTTPS access >>", "<< CIDR_2 allowed for HTTPS access >>", ...]
    }
    "udp1" = {
      protocol = "udp"
      port     = "5000"
      cidrs    = ["0.0.0.0/0"]
    }
    "udp2" = {
      protocol = "udp"
      port     = "31283"
      cidrs    = ["0.0.0.0/0"]
    }
  }
}

output "copilot_public_ip" {
  value = module.copilot_build_gcp.public_ip
}

output "copilot_private_ip" {
  value = module.copilot_build_gcp.private_ip
}
```

### Variables

> **NOTE:** If **use_existing_network** is set to true, **network** and **subnetwork** are required. Make sure that resources `google_compute_network` and `google_compute_subnetwork` are configured properly.

- **use_existing_network**

  Flag to indicate whether to use an existing network. Default: false.

- **network**

  The name or self_link of an existing Google Compute Network. If not set, a Google Compute Network and Subnetwork with cidr "10.128.0.0/9" will be created.

- **subnetwork**

  The name or self_link of an existing Google Compute Subnetwork of the given **network**. **subnetwork** must be empty if **network** is not provided.

- **subnet_cidr**

  The CIDR for the Google Subnetwork that will be created. Must be empty if **network** is set. Default value is "10.128.0.0/9".

- **copilot_name**

  Name of copilot that will be launched. If not set, default name will be used.

- **service_account_email**

  Email of a service account to attach to the Aviatrix Copilot instance. If not set, no service account will be attached.

- **service_account_scopes**

  List of scopes to assign to the service account. If not set, defaults to ["cloud-platform"].

- **copilot_machine_type**

  The machine type to create the Aviatrix Copilot. If not set, defaults to "e2-standard-2".

- **boot_disk_size**

  Boot disk size for copilot. The minimum boot disk size is 30G. Default: 30.

- **allowed_cidrs**

  Map of allowed incoming CIDRs. Please set protocol(string), port(string) and cidrs(set of strings) in each map element. Please see the example code above for example.

> **NOTE:** If **ssh_user** is not set, no SSH key will be added to Copilot. If **use_existing_ssh_key** is set to false, an SSH key will be generated and added to Copilot. If **use_existing_ssh_key** is set to true, **ssh_public_key_file_path** is required.

- **ssh_user**

  SSH user name. If not set, defaults to "".

- **use_existing_ssh_key**

  Flag to indicate whether to use an existing ssh key. Default: false.

- **ssh_public_key_file_path**

  File path to the SSH public key. If not set, defaults to "".

- **default_data_disk_size**

  Size of default data disk. If not set, no default data disk will be created. Default: 0.

- **additional_disks**

  A set of additional disks' IDs that will be attached to the copilot instance. If not set, defaults to [].

### Outputs

- **private_ip**

  The private IP address of the Google Compute instance created for the copilot.

- **public_ip**

  The public IP address of the Google Compute instance created for the copilot.
