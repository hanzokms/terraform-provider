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
    # organization_slug = "<organization slug to scope the session to sub-org>"
    universal = {
      client_id     = "<machine-identity-client-id>"
      client_secret = "<machine-identity-client-secret>"
    }
  }
}
