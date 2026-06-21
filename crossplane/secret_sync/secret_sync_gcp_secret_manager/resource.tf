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

resource "kms_secret_sync_gcp_secret_manager" "secret_manager_test" {
  name          = "gcp-sync-tests"
  description   = "I am a test secret sync"
  project_id    = "f4517f4c-8b61-4727-8aef-5ae2807126fb"
  environment   = "prod"
  secret_path   = "/"
  connection_id = "<app-connection-id>"

  sync_options       = "{\"initial_sync_behavior\":\"import-prioritize-destination\"}"
  destination_config = "{\"project_id\":\"my-duplicate-project\"}"
}
