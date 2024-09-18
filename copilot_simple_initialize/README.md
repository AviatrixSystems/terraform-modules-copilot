## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [http_http.copilot_init_simple](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [http_http.copilot_login](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_avx_controller_password"></a> [avx\_controller\_password](#input\_avx\_controller\_password) | The password to login to the Aviatrix Controller | `string` | n/a | yes |
| <a name="input_avx_controller_public_ip"></a> [avx\_controller\_public\_ip](#input\_avx\_controller\_public\_ip) | The public IP address of the Aviatrix Controller | `string` | n/a | yes |
| <a name="input_avx_controller_username"></a> [avx\_controller\_username](#input\_avx\_controller\_username) | The username to login to the Aviatrix Controller | `string` | n/a | yes |
| <a name="input_avx_copilot_public_ip"></a> [avx\_copilot\_public\_ip](#input\_avx\_copilot\_public\_ip) | The public IP address of the Aviatrix CoPilot | `string` | n/a | yes |
| <a name="input_copilot_service_account_password"></a> [copilot\_service\_account\_password](#input\_copilot\_service\_account\_password) | The password to login to the Aviatrix CoPilot | `string` | n/a | yes |
| <a name="input_copilot_service_account_username"></a> [copilot\_service\_account\_username](#input\_copilot\_service\_account\_username) | The username to login to the Aviatrix CoPilot | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_copilot_init_simple_result"></a> [copilot\_init\_simple\_result](#output\_copilot\_init\_simple\_result) | n/a |
