# Hanzo KMS Terraform Provider 

# Usage 

```
terraform {
  required_providers {
    kms = {
      # version = <latest version>
      source = "hanzokms/kms"
    }
  }
}

provider "kms" {
  host          = "https://kms.hanzo.ai" # Only required if using self hosted instance of Hanzo KMS, default is https://kms.hanzo.ai
  client_id     = "<>"
  client_secret = "<>"
}

data "kms_secrets" "common-secrets" {
  env_slug     = "dev"
  workspace_id = "PROJECT_ID"
  folder_path  = "/some-folder/another-folder"
}

data "kms_secrets" "backend-secrets" {
  env_slug     = "prod"
  workspace_id = "PROJECT_ID"
  folder_path  = "/"
}

output "all-project-secrets" {
  value = data.kms_secrets.backend-secrets
}

output "single-secret" {
  value = data.kms_secrets.backend-secrets.secrets["SECRET-NAME"]
}
```

# Development  
Tutorials for creating Terraform providers can be found on the [HashiCorp Learn](https://learn.hashicorp.com/collections/terraform/providers-plugin-framework) platform. _Terraform Plugin Framework specific guides are titled accordingly._

## Requirements

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Go](https://golang.org/doc/install) >= 1.19

## Developing the Provider

If you wish to work on the provider, you'll first need [Go](http://www.golang.org) installed on your machine (see [Requirements](#requirements) above).

To compile the provider, run `go install`. This will build the provider and put the provider binary in the `$GOPATH/bin` directory.

To generate or update documentation, run `go generate`.

In order to run the full suite of Acceptance tests, run `make testacc`.

*Note:* Acceptance tests create real resources, and often cost money to run.

```shell
make testacc
```
