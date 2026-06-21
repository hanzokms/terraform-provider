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

resource "kms_secret" "mongo_secret" {
  name         = "MONGO_DB"
  value        = "<some-key>"
  env_slug     = "dev"
  workspace_id = "PROJECT_ID"
  folder_path  = "/"
}

resource "kms_secret" "smtp_secret" {
  name         = "SMTP"
  value        = "<some key>"
  env_slug     = "dev"
  workspace_id = "PROJECT_ID"
  folder_path  = "/mail-service"
  secret_reminder = {
    note        = "Rotate this secret using X API"
    repeat_days = 30
  }
}


resource "kms_secret_tag" "terraform" {
  name       = "terraform"
  slug       = "terraform"
  color      = "#fff"
  project_id = "PROJECT_ID"
}

resource "kms_secret" "github_action_secret" {
  name         = "GITHUB_ACTION"
  value        = "<some value>"
  env_slug     = "dev"
  workspace_id = "PROJECT_ID"
  folder_path  = "/"
  tag_ids      = [kms_secret_tag.terraform.id]
}

# Ephemeral resource (requires Terraform 1.10.0+)
# https://www.hashicorp.com/blog/terraform-1-10-improves-handling-secrets-in-state-with-ephemeral-values
ephemeral "kms_secret" "ephemeral-secret" {
  name         = "SECRET-KEY"
  env_slug     = "dev"
  workspace_id = "PROJECT_ID"
  folder_path  = "/"
}
