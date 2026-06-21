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

resource "kms_app_connection_cloudflare" "app-connection-cloudflare" {
  name   = "cloudflare-app-connection"
  method = "api-token"
  credentials = {
    account_id = "<cloudflare-account-id>"
    api_token  = "<cloudflare-api-token>"
  }
  description = "I am a Cloudflare app connection"
}