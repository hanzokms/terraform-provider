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

resource "kms_integration_circleci" "circleci-integration" {
  project_id  = "225393b9-e3d6-424f-9df3-22c3cdeb97c9"
  environment = "dev"
  secret_path = "/test-folder"

  circleci_token      = "<your-circle-cipersonal-access-token>"
  circleci_project_id = "<your-circleci-project-id>"
  circleci_org_slug   = "<your-circleci-org-slug>"
}
