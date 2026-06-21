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

resource "kms_app_connection_mysql" "mysql-demo" {
  name        = "mysql-demo"
  description = "This is a demo mysql connection."
  method      = "username-and-password"
  credentials = {
    host        = "example.com"
    port        = 3306
    database    = "default"
    username    = "root"
    password    = "<password>"
    ssl_enabled = false
  }
}
