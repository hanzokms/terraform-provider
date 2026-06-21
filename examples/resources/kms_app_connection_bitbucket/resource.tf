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

resource "kms_app_connection_bitbucket" "example" {
  name        = "bitbucket-connection"
  description = "I am a test app connection"
  method      = "api-token"

  credentials = {
    email     = "your-bitbucket-email@example.com"
    api_token = "your-bitbucket-api-token"
  }
}