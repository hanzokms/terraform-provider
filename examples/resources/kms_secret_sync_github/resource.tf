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

resource "kms_secret_sync_github" "example-github-secret-sync" {
  name          = "github-secret-sync-demo"
  description   = "Demo of Github secret sync"
  project_id    = "<project-id>"
  environment   = "<environment-slug>"
  secret_path   = "/" # Root folder is /
  connection_id = "<github-app-connection-id>"

  sync_options = {
    initial_sync_behavior   = "overwrite-destination", # Supported options: overwrite-destination
    disable_secret_deletion = false,
    key_schema              = "KMS_{{secretKey}}" # Optional, but recommended
  }

  destination_config = {
    scope            = "repository"                # Supported options: repository|organization|repository-environment
    repository_owner = "<github-repository-owner>" # The github organization name or github username for personal repositories
    repository_name  = "<github-repository-name>"  # The github repository name
  }
}
