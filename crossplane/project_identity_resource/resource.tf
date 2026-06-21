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

resource "kms_project" "example" {
  name = "example"
  slug = "example"
}

resource "kms_project_identity" "test-identity" {
  project_id  = kms_project.example.id
  identity_id = "<identity id>"
  roles = "[{\"role_slug\": \"admin\"}]"
}
