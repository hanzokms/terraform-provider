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

resource "kms_app_connection_databricks" "example" {
  name        = "databricks-connection"
  description = "I am a test app connection"
  method      = "service-principal"

  credentials = {
    client_id     = "your-databricks-client-id"
    client_secret = "your-databricks-client-secret"
    workspace_url = "https://your-workspace.cloud.databricks.com"
  }
}
