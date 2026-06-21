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

resource "kms_app_connection_ldap" "ldap-demo" {
  name        = "ldap-demo"
  description = "This is a demo LDAP connection."
  method      = "simple-bind"
  credentials = {
    provider                = "active-directory"
    url                     = "ldap://ldap.example.com:389"
    dn                      = "cn=admin,dc=example,dc=com"
    password                = "<password>"
    ssl_reject_unauthorized = false
  }
}

# Example with LDAPS (secure LDAP)
resource "kms_app_connection_ldap" "ldap-demo-secure" {
  name        = "ldap-demo-secure"
  description = "This is a demo LDAP connection with SSL."
  method      = "simple-bind"
  credentials = {
    provider                = "active-directory"
    url                     = "ldaps://ldap.example.com:636"
    dn                      = "cn=admin,dc=example,dc=com"
    password                = "<password>"
    ssl_reject_unauthorized = true
    ssl_certificate         = file("${path.module}/ca.pem")
  }
}
