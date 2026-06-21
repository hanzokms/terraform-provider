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

resource "kms_secret_approval_policy" "prod-policy" {
  project_id        = kms_project.example.id
  name              = "my-prod-policy"
  environment_slugs = ["prod"]
  secret_path       = "/"
  approvers = [
    {
      type = "group"
      id   = "52c70c28-9504-4b88-b5af-ca2495dd277d"
    },
    {
      type     = "user"
      username = "name@hanzo.ai"
  }]
  required_approvals = 1
  enforcement_level  = "hard"
}
