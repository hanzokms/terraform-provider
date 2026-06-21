terraform {
  required_providers {
    kms = {
      # version = <latest version>
      source = "hanzokms/kms"
    }
  }
}

provider "kms" {
  host = "https://kms.hanzo.ai" # Only required if using self hosted instance of Hanzo KMS, default is https://kms.hanzo.ai
  auth = {
    universal = {
      client_id     = "<machine-identity-client-id>"
      client_secret = "<machine-identity-client-secret>"
    }
  }
}

resource "kms_app_connection_1password" "one-password-demo" {
  name        = "1password-demo"
  description = "This is a demo 1password connection."
  method      = "api-token"
  credentials = {
    instance_url = "<https://1pass.example.com>"
    api_token    = "<API_TOKEN>"
  }
}
