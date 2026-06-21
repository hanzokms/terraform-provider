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

resource "kms_secret_sync_flyio" "example" {
  name          = "flyio-secret-sync"
  description   = "Sync secrets to Fly.io app"
  project_id    = "<your-kms-project-id>"
  connection_id = "<app-connection-id>" # The ID of your Fly.io App Connection
  environment   = "<env-slug>"
  secret_path   = "<kms-secret-path>"

  auto_sync_enabled = true

  destination_config = {
    app_id = "<flyio-app-id>"
  }

  sync_options = {
    initial_sync_behavior   = "overwrite-destination"
    disable_secret_deletion = false
    key_schema              = "{{secretKey}}-{{environment}}"
  }
}