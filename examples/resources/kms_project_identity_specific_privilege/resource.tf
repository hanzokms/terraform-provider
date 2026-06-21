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
  roles = [
    {
      role_slug = "admin"
    }
  ]
}

resource "kms_project_identity_specific_privilege" "test-privilege" {
  project_slug = kms_project.example.slug
  identity_id  = kms_project_identity.test-identity.identity_id
  permissions_v2 = [
    {
      action   = ["edit"]
      subject  = "secret-folders",
      inverted = true,
    },
    {
      action  = ["read", "edit"]
      subject = "secrets",
      conditions = jsonencode({
        environment = {
          "$in" = ["dev", "prod"]
          "$eq" = "dev"
        }
        secretPath = {
          "$eq" = "/"
        }
      })
    },
  ]
}
