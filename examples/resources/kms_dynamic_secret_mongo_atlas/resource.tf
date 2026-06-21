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


resource "kms_dynamic_secret_mongo_atlas" "mongo-atlas" {
  name             = "mongo-atlas-dynamic-secret-example"
  project_slug     = "your-project-slug"
  environment_slug = "dev"
  path             = "/"
  default_ttl      = "1h"
  max_ttl          = "4h"

  configuration = {
    admin_public_key  = "your-admin-public-key"
    admin_private_key = "your-admin-private-key"
    group_id          = "your-group-id"

    roles = [
      {
        database_name = "my-application-db"
        role_name     = "readWrite"
      }
    ]

    # Optional
    scopes = [
      {
        name = "myCluster"
        type = "CLUSTER"
      }
    ]
  }

  username_template = "{{randomUsername}}"
}
