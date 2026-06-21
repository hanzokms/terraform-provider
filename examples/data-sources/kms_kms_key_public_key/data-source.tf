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

# Get public key information for a signing KMS key
data "kms_kms_key_public_key" "example" {
  key_id = "<your-signing-kms-key-id>"
}

# Output the public key
output "public_key" {
  value       = data.kms_kms_key_public_key.example.public_key
  description = "The public key for cryptographic operations"
}

# Output available signing algorithms
output "signing_algorithms" {
  value       = data.kms_kms_key_public_key.example.signing_algorithms
  description = "Available signing algorithms for this key"
}