terraform {
  required_providers {
    kms = {
      source = "hanzokms/kms"
    }
  }
}

provider "kms" {
  host          = "https://kms.hanzo.ai"
  service_token = "<>"
}

data "kms_secrets" "edu" {}

output "secrets" {
  value     = data.kms_secrets.edu.secrets.maidul
  sensitive = false
}
