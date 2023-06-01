// Create service account identity

module "retool_service_account" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "4.2.0"

  project_id = var.project_id
  names      = ["retool"]
  project_roles = [
    "${var.project_id}=>roles/cloudsql.client",
    "${var.project_id}=>roles/secretmanager.secretAccessor",
  ]
}
