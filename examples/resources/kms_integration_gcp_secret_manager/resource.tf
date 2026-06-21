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

variable "service_account_json" {
  type        = string
  description = "Google Cloud service account JSON key"
}



resource "kms_integration_gcp_secret_manager" "gcp-integration" {
  project_id           = "your-project-id"
  service_account_json = var.service_account_json
  environment          = "dev"
  secret_path          = "/"
  gcp_project_id       = "gcp-project-id"

}
