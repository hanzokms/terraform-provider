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

resource "kms_secret_sync_supabase" "example" {
  name          = "supabase-secret-sync"
  description   = "Sync secrets to Supabase project"
  project_id    = "<your-kms-project-id>"
  connection_id = "<app-connection-id>" # The ID of your Supabase App Connection
  environment   = "<env-slug>"
  secret_path   = "<kms-secret-path>"

  auto_sync_enabled = true

  sync_options = "{\"initial_sync_behavior\":\"overwrite-destination\",\"disable_secret_deletion\":false,\"key_schema\":\"{{secretKey}}-{{environment}}\"}"

  destination_config = "{\"project_id\":\"<supabase-project-id>\",\"project_name\":\"<supabase-project-name>\"}"
}
