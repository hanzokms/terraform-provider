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


data "kms_secret_folders" "folders" {
  environment_slug = "dev"
  project_id       = "<PROJECT_ID>"
  folder_path      = "/"
}

output "secret-folders" {
  value = data.kms_secret_folders.folders
}
