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

resource "kms_app_connection_azure_app_configuration" "app_connection_azure_app_configuration" {
  name   = "app-connection-azure-app-configuration"
  method = "client-secret"
  credentials = {
    tenant_id     = "<azure-tenant-id>"
    client_id     = "<azure-client-id>"
    client_secret = "<azure-client-secret>"
  }
  description = "I am a test Azure app configuration app connection using client credentials"
}
