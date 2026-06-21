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

resource "kms_project" "gcp-project" {
  name        = "GCP Project"
  slug        = "gcp-project"
  description = "This is a GCP project"
  type        = "secret-manager" # Default project type
}

resource "kms_project" "aws-project" {
  name        = "AWS Project"
  slug        = "aws-project"
  description = "This is an AWS project"
  type        = "secret-manager"
}

resource "kms_project" "kms-project" {
  name        = "KMS Project"
  slug        = "kms-project"
  description = "This is a KMS project for key management"
  type        = "kms"
}

resource "kms_project" "certificate-project" {
  name        = "Certificates Project"
  slug        = "certificate-project"
  description = "This is a certificates project for certificate management"
  type        = "cert-manager"
}
