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

  sync_options = "{\"initial_sync_behavior\":\"overwrite-destination\",\"disable_secret_deletion\":false,\"key_schema\":\"KMS_{{secretKey}}\"}"

  destination_config = "{\"scope\":\"repository\",\"repository_owner\":\"<github-repository-owner>\",\"repository_name\":\"<github-repository-name>\"}"
}
