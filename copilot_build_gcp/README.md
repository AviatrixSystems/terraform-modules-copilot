# Aviatrix Copilot Build GCP

This module builds an Aviatrix Copilot in GCP.

### Usage:

To create an Aviatrix Copilot:

```
provider "google" {
}

terraform {
  required_providers{
    google = {
      source = "hashicorp/google"
      version = "4.0.0"
    }
  }
}

module "copilot_build_gcp" {
  source          = "git@github.com:AviatrixSystems/terraform-modules-copilot/copilot_build_gcp.git"
  copilot_name    = "copilot"
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

- **allowed_cidrs**

  Map of allowed incoming CIDRs. Please set protocol(string), port(string) and cidrs(set of strings) in each map element. Please see the example code above for example.

### Outputs

- **private_ip**

  The private IP address of the Google Compute instance created for the copilot.

- **public_ip**

  The public IP address of the Google Compute instance created for the copilot.
