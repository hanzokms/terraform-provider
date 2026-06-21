terraform {
  required_providers {
    kms = {
      # version = <latest version>
      source = "hanzokms/kms"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.25.0"
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

ephemeral "kms_secret" "postgres_username" {
  name         = "POSTGRES_USERNAME"
  env_slug     = "dev"
  workspace_id = "PROJECT_ID"
  folder_path  = "/"
}

ephemeral "kms_secret" "postgres_password" {
  name         = "POSTGRES_PASSWORD"
  env_slug     = "dev"
  workspace_id = "PROJECT_ID"
  folder_path  = "/"
}

locals {
  credentials = {
    username = ephemeral.kms_secret.postgres_username.value
    password = ephemeral.kms_secret.postgres_password.value
  }
}

provider "postgresql" {
  host     = data.aws_db_instance.example.address
  port     = data.aws_db_instance.example.port
  username = local.credentials["username"]
  password = local.credentials["password"]
}
