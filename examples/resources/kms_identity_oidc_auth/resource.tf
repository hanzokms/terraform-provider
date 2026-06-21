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
  org_id = "<>"
}

resource "kms_identity_oidc_auth" "oidc-auth" {
  identity_id        = kms_identity.machine-identity-1.id
  oidc_discovery_url = "<>"
  bound_issuer       = "<>"
  bound_audiences    = ["sample-audience"]
  bound_subject      = "<>"
}
