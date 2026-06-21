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

resource "kms_project_role" "biller" {
  project_slug = kms_project.example.slug
  name         = "Tester"
  description  = "A test role"
  slug         = "tester"
  permissions  = "[{\"action\":[\"read\",\"create\"],\"subject\":\"integrations\"},{\"action\":[\"read\",\"edit\"],\"subject\":\"secrets\",\"conditions\":{\"environment\":{\"$eq\":\"dev\",\"$in\":[\"dev\",\"prod\"]},\"secretPath\":{\"$eq\":\"/\"}}}]"
}
