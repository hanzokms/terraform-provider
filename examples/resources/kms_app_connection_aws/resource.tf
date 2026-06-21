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

resource "kms_app_connection_aws" "app-connection-aws-assume-role" {
  name   = "aws-assume-role-app-connection"
  method = "assume-role"
  credentials = {
    role_arn = "<assume role arn>"
  }
  description = "I am a test app connection"
}

resource "kms_app_connection_aws" "app-connection-aws-access-key" {
  name   = "aws-access-key-app-connection"
  method = "access-key"
  credentials = {
    access_key_id     = "<access-key-id>",
    secret_access_key = "<secret-access-key>",
  }
  description = "I am a test app connection"
}
