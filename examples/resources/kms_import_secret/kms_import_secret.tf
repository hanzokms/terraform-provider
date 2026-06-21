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

resource "kms_secret_import" "custom-import" {
  environment_slug        = "<ENV_SLUG>"
  import_environment_slug = "<ENV_SLUG>"
  is_replication          = false
  project_id              = "<PROJECT-ID>"
  folder_path             = "<FOLDER_PATH>"
  import_folder_path      = "<IMPORT_FOLDER_PATH>"
}
