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

resource "kms_integration_databricks" "db-integration" {
  project_id  = "<project-id>"
  environment = "<env-slug>"

  databricks_host         = "<databricks-host>" # Example: https://afc-2a42f142-bb11.cloud.databricks.com
  databricks_token        = "<databricks-personal-access-token>"
  databricks_secret_scope = "<databricks-secret-scope>"

  secret_path = "/some/kms/folder" # "/" is the root folder 

}
