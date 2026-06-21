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

# Create an encryption KMS key
resource "kms_kms_key" "encryption_key" {
  project_id           = "<your-project-id>"
  name                 = "my-encryption-key"
  description          = "KMS key for encrypting sensitive data"
  key_usage            = "encrypt-decrypt"
  encryption_algorithm = "aes-256-gcm"
}

# Create a signing KMS key
resource "kms_kms_key" "signing_key" {
  project_id           = "<your-project-id>"
  name                 = "my-signing-key"
  description          = "KMS key for digital signatures"
  key_usage            = "sign-verify"
  encryption_algorithm = "RSA_4096"
}