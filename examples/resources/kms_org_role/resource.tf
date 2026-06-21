terraform {
  required_providers {
    kms = {
      # version = <latest version>
      source = "hanzokms/kms"
    }
  }
}

provider "kms" {
  host = "http://kms.hanzo.ai" # Only required if using self hosted instance of Hanzo KMS, default is https://kms.hanzo.ai
  auth = {
    universal = {
      client_id     = "<machine-identity-client-id>"
      client_secret = "<machine-identity-client-secret>"
    }
  }
}

resource "kms_org_role" "tester" {
  name        = "Tester"
  description = "A test role"
  slug        = "tester"
  permissions = [
    {
      subject = "project"
      action  = ["create"]
    },
    {
      subject = "app-connections"
      action  = ["read", "create"]
      conditions = jsonencode({
        connectionId = {
          "$eq" = "<connection-id>"
        }
      })
    },
  ]
}

