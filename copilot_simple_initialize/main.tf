terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
    }
  }
}

data "http" "copilot_login" {
  url      = "https://${var.avx_controller_public_ip}/v2/api"
  insecure = true
  method   = "POST"
  request_headers = {
    "Content-Type" = "application/json"
  }
  request_body = jsonencode({
    "action" : "login",
    "username" : var.avx_controller_username,
    "password" : var.avx_controller_password,
  })
  retry {
    attempts     = 30
    min_delay_ms = 10000
  }
  lifecycle {
    postcondition {
      condition     = jsondecode(self.response_body)["return"]
      error_message = "Failed to login to the controller: ${jsondecode(self.response_body)["reason"]}"
    }
  }
}

data "http" "copilot_init_simple" {
  url      = "https://${var.avx_copilot_public_ip}/v1/api/single-node"
  insecure = true
  method   = "POST"
  request_headers = {
    "Content-Type" = "application/json"
    "CID": jsondecode(data.http.copilot_login.response_body)["CID"]
  }
  request_body = jsonencode({
    "taskserver": {
      "username": var.copilot_service_account_username,
      "password": var.copilot_service_account_password,
    }
  })
  retry {
    attempts     = 20
    min_delay_ms = 15000
  }
}

output "copilot_init_simple_result" {
  value = data.http.copilot_init_simple.response_body
}
