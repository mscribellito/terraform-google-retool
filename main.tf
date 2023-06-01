// Enable necessary APIs & services

resource "google_project_service" "activate_apis" {
  for_each = toset(var.activate_apis)

  project = var.project_id
  service = each.value
}

resource "time_sleep" "wait_activate_apis" {
  create_duration = "120s"

  depends_on = [google_project_service.activate_apis]
}

locals {
  secret_database_password = "retool-database-password"
  secret_jwt_secret        = "retool-jwt-secret"
  secret_encryption_key    = "retool-encryption-key"
  secret_license_key       = "retool-license-key"

  database_name = "hammerhead_production"
  database_user = "retool"

  env_vars = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "POSTGRES_DB"
      value = local.database_name
    },
    {
      name  = "POSTGRES_HOST"
      value = "/cloudsql/${module.retool_database.instance_connection_name}"
    },
    {
      name  = "POSTGRES_SSL_ENABLED"
      value = "false"
    },
    {
      name  = "POSTGRES_PORT"
      value = "5432"
    },
    {
      name  = "POSTGRES_USER"
      value = local.database_user
    }
  ]

  env_secret_vars = [
    {
      name       = "POSTGRES_PASSWORD"
      value_from = local.secret_database_password
    },
    {
      name       = "JWT_SECRET"
      value_from = local.secret_jwt_secret
    },
    {
      name       = "ENCRYPTION_KEY"
      value_from = local.secret_encryption_key
    },
    {
      name       = "LICENSE_KEY"
      value_from = local.secret_license_key
    }
  ]
}
