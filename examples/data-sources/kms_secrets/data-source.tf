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

data "kms_secrets" "common_secrets" {
  env_slug     = "dev"
  workspace_id = "<project id>" // project ID
  folder_path  = "/"
}

output "all-project-secrets" {
  value = nonsensitive(data.kms_secrets.common_secrets.secrets["SECRET-NAME"].value)
}

output "all-project-secrets" {
  value = nonsensitive(data.kms_secrets.common_secrets.secrets["SECRET-NAME"].comment)
}
