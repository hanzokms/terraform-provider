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

resource "kms_secret_rotation_mysql_credentials" "mysql-credentials" {
  name          = "mysql-credentials-secret-rotation-example"
  project_id    = "<project-id>"
  environment   = "<environment-slug>"
  secret_path   = "<secret-path>" # Root folder is /
  connection_id = "<app-connection-id>"

  parameters = {
    username1 = "kms_user1"
    username2 = "kms_user2"
  }

  secrets_mapping = {
    username = "MYSQL_USERNAME"
    password = "MYSQL_PASSWORD"
  }
}
