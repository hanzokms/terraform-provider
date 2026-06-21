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
  org_id = "<your-org-id>"
}

resource "kms_identity_token_auth" "token-auth" {
  identity_id = kms_identity.machine-identity-1.id
}

resource "kms_identity_token_auth_token" "token-auth-token" {
  identity_id = kms_identity.machine-identity-1.id
  name        = "token-auth-token"

  depends_on = [kms_identity_token_auth.token-auth]
}

output "token-auth-token" {
  sensitive = true
  value     = kms_identity_token_auth_token.token-auth-token.token
}
