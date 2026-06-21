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

resource "kms_app_connection_1password" "one-password-app-connection-demo" {
  name        = "1password-app-connection-demo"
  description = "This is a demo 1Password App Connection."
  method      = "api-token"
  credentials = {
    instance_url = "<https://1pass.example.com>"
    api_token    = "<API_TOKEN>"
  }
}

resource "kms_secret_sync_1password" "one-password-secret-sync-demo" {
  name          = "1password-secret-sync-demo"
  description   = "This is a demo 1Password Secret Sync."
  project_id    = "<project-id>"
  environment   = "<environment-slug>"
  secret_path   = "<secret-path>"
  connection_id = kms_app_connection_1password.one-password-app-connection-demo.id
  destination_config = {
    vault_id    = "<vault-id>"
    value_label = "<value-label>" # Optional, defaults to `value`
  }
  sync_options = {
    initial_sync_behavior = "<initial-sync-behavior>" # Supported options: overwrite-destination|import-prioritize-source|import-prioritize-destination
    key_schema            = "<key-schema>"            // Optional
  }
}
