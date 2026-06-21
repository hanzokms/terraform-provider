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

resource "kms_project" "example" {
  name = "example"
  slug = "example"
}

resource "kms_project_group" "group" {
  project_id = kms_project.example.id

  # Either group_id or group_name is required.
  group_id   = "<>"
  group_name = "<>"
  roles = [
    {
      role_slug                   = "admin",
      is_temporary                = true,
      temporary_access_start_time = "2024-09-19T12:43:13Z",
      temporary_range             = "1y"
    },
    {
      role_slug = "my-custom-role",
    },
  ]
}
