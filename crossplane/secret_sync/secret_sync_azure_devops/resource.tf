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

resource "kms_secret_sync_azure_devops" "demo-azure-devops-sync" {
  name          = "demo-sync"
  description   = "This is a demo sync."
  project_id    = "<project-id>"
  environment   = "dev"
  secret_path   = "/"
  connection_id = "<app-connection-id>" # The ID of your Azure DevOps App Connection

  sync_options = "{}"

  destination_config = "{\"devops_project_id\":\"<devops-project-id>\"}"
}
