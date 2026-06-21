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

resource "kms_secret_sync_cloudflare_pages" "cloudflare-pages-secret-sync" {
  name          = "cloudflare-pages-secret-sync-demo"
  description   = "Demo of Cloudflare Pages secret sync"
  project_id    = "<project-id>"
  environment   = "<environment-slug>"
  secret_path   = "<secret-path>" # Root folder is /
  connection_id = "<cloudflare-app-connection-id>"

  sync_options = {
    initial_sync_behavior   = "overwrite-destination" # Supported options: overwrite-destination, import-prioritize-source, import-prioritize-destination
    disable_secret_deletion = false
    key_schema              = "<key-schema>" # Optional: The format to use for structuring secret keys
  }

  destination_config = {
    project_name = "<cloudflare-pages-project-name>"
    environment  = "production" # or "preview"
  }
}