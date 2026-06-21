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

resource "kms_secret_rotation_azure_client_secret" "azure-client-secret" {
  name          = "azure-client-secret-secret-rotation-example"
  project_id    = "<project-id>"
  environment   = "<environment-slug>"
  secret_path   = "<secret-path>" # Root folder is /
  connection_id = "<app-connection-id>"

  parameters = {
    object_id = "<azure-app-id>"
    client_id = "<azure-app-client-id>"
  }

  secrets_mapping = {
    client_id     = "AZURE_CLIENT_ID"
    client_secret = "AZURE_CLIENT_SECRET"
  }
}
