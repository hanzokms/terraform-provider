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

resource "kms_secret_folder" "folder-1" {
  name             = "folder-1"
  environment_slug = "dev"
  project_id       = "<PROJECT-ID>"
  folder_path      = "/"
  # force_delete     = true
}

resource "kms_secret_folder" "folder-2" {
  name             = "folder-2"
  environment_slug = "prod"
  project_id       = "<PROJECT-ID>"
  folder_path      = "/nested"
  # force_delete     = false
}

