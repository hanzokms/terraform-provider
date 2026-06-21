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
  name     = "example"
  slug     = "example"
  position = 1 # Optional
}

resource "kms_project_environment" "pre-prod" {
  name       = "pre-prod"
  project_id = kms_project.example.id
  slug       = "preprod"
  position   = 2 # Optional
}
