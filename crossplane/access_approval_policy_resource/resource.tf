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
    universal_auth = {
      client_id     = "<machine-identity-client-id>"
      client_secret = "<machine-identity-client-secret>"
    }
  }
}


resource "kms_access_approval_policy" "prod-policy" {
  project_id        = "5156a345-e460-416b-84fc-b14b426b1cb3"
  name              = "my-approval-policy"
  environment_slugs = ["prod"]
  secret_path       = "/"

  group_approvers = [
    // array of group IDs
    "60782603-18bd-4f83-a312-6a9c501f4914",
  ]
  user_approvers = [
    // array of usernames
    "vlad@hanzo.ai",
  ]

  required_approvals = 1
  enforcement_level  = "soft"
}
