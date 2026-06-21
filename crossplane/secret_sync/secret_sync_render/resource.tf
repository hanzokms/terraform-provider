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


resource "kms_secret_sync_render" "render-secret-sync-demo" {
  name          = "render-secret-sync-demo"
  description   = "This is a demo Render Secret Sync."
  project_id    = "<project-id>"
  environment   = "<environment-slug>"
  secret_path   = "<secret-path>"
  connection_id = "<app-connection-id>"

  sync_options = "{\"initial_sync_behavior\":\"<initial-sync-behavior>\",\"key_schema\":\"<key-schema>\"}"

  destination_config = "{\"service_id\":\"<service-id>\",\"scope\":\"<scope>\",\"type\":\"<type>\"}"
}
