resource "kms_project" "pki" {
  name        = "PKI Project"
  slug        = "pki-project"
  type        = "cert-manager"
  description = "Project for managing SSL/TLS certificates"
}

resource "kms_cert_manager_external_ca_adcs" "adcs" {
  project_slug = kms_project.pki.slug

  name   = "corporate-adcs"
  status = "active"

  azure_adcs_connection_id = "your-azure-adcs-connection-id"
}
