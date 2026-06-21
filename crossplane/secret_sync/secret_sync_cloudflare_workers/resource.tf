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

resource "kms_secret_sync_cloudflare_workers" "cloudflare-workers-secret-sync" {
  name          = "cloudflare-workers-secret-sync-demo"
  description   = "Demo of Cloudflare Workers secret sync"
  project_id    = "<project-id>"
  environment   = "<environment-slug>"
  secret_path   = "<secret-path>" # Root folder is /
  connection_id = "<cloudflare-app-connection-id>"

  sync_options = "{\"initial_sync_behavior\":\"overwrite-destination\",\"disable_secret_deletion\":false,\"key_schema\":\"<key-schema>\"}"

  destination_config = "{\"script_id\":\"<cloudflare-workers-script-id>\"}"
}
