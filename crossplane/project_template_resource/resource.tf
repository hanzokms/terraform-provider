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

resource "kms_project_template" "example-project-template" {
  name         = "example-project-template"
  description  = "This is an example project template"
  type         = "secret-manager"
  environments = "[{\"name\":\"development\",\"slug\":\"dev\",\"position\":1}]"
  roles        = "[{\"name\":\"Test\",\"slug\":\"test\",\"permissions\":[{\"action\":[\"edit\"],\"subject\":\"secrets\",\"inverted\":true},{\"action\":[\"read\",\"edit\"],\"subject\":\"secrets\",\"conditions\":{\"environment\":{\"$in\":[\"dev\",\"prod\"],\"$eq\":\"dev\"},\"secretPath\":{\"$eq\":\"/\"}}}]}]"
}
