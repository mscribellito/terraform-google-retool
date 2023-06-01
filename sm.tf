resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "encryption_key" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "jwt_secret" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

// Create secrets database password, JWT secret, encryption key & license key

module "retool_secrets" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "0.1.1"

  project_id = var.project_id

  secrets = [
    {
      name                  = local.secret_database_password
      automatic_replication = true
      secret_data           = random_password.password.result
    },
    {
      name                  = local.secret_jwt_secret
      automatic_replication = true
      secret_data           = random_password.jwt_secret.result
    },
    {
      name                  = local.secret_encryption_key
      automatic_replication = true
      secret_data           = random_password.encryption_key.result
    },
    {
      name                  = local.secret_license_key
      automatic_replication = true
      secret_data           = var.retool_license_key
    }
  ]

  depends_on = [time_sleep.wait_activate_apis]
}

data "google_secret_manager_secret_version" "retool_database_password" {
  project = var.project_id

  secret = local.secret_database_password

  depends_on = [module.retool_secrets]
}
