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

resource "kms_identity" "machine-identity-1" {
  name   = "machine-identity-1"
  role   = "admin"
  org_id = "601815be-6884-4ee4-86c7-bfc6415f2123"
}

resource "kms_identity_azure_auth" "azure-auth" {
  identity_id                   = kms_identity.machine-identity-1.id
  tenant_id                     = "<>"
  resource_url                  = "https://management.azure.com/"
  allowed_service_principal_ids = ["<>", "<>"]
  access_token_ttl              = 2592000
  access_token_max_ttl          = 2592000
}
