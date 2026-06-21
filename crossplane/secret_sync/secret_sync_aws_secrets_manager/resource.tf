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

resource "kms_secret_sync_aws_secrets_manager" "aws-secrets-manager-secret-sync" {
  name          = "aws-secrets-manager-secret-sync-demo"
  description   = "Demo of AWS Secrets Manager secret sync"
  project_id    = "<project-id>"
  environment   = "<environment-slug>"
  secret_path   = "<secret-path>" # Root folder is /
  connection_id = "<app-connection-id>"

  sync_options = "{\"initial_sync_behavior\":\"overwrite-destination\",\"aws_kms_key_id\":\"<aws-kms-key-id>\",\"sync_secret_metadata_as_tags\":false,\"tags\":[{\"key\":\"tag-1\",\"value\":\"tag-1-value\"},{\"key\":\"tag-2\",\"value\":\"tag-2-value\"}]}"

  destination_config = "{\"aws_region\":\"<aws-region>\",\"mapping_behavior\":\"many-to-one\",\"aws_secrets_manager_secret_name\":\"<aws-secret-name>\"}"
}
