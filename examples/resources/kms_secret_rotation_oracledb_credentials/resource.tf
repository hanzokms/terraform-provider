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

resource "kms_secret_rotation_oracledb_credentials" "oracledb-credentials" {
  name          = "oracledb-credentials-secret-rotation-example"
  project_id    = "<project-id>"
  environment   = "<environment-slug>"
  secret_path   = "<secret-path>" # Root folder is /
  connection_id = "<app-connection-id>"

  parameters = {
    username1 = "KMS_USER_1"
    username2 = "KMS_USER_2"
  }

  secrets_mapping = {
    username = "ORACLEDB_USERNAME"
    password = "ORACLEDB_PASSWORD"
  }
}