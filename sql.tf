// Create storage database

module "retool_database" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = "15.0.0"

  name             = "retool"
  database_version = var.database_version
  project_id       = var.project_id
  zone             = var.zone
  region           = var.region
  tier             = var.database_tier

  additional_databases = [
    {
      name      = local.database_name
      charset   = "UTF8"
      collation = "en_US.UTF8"
    }
  ]

  enable_default_db   = false
  enable_default_user = false

  deletion_protection = true

  ip_configuration = {
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = true
    allocated_ip_range  = null
    authorized_networks = []
  }

  create_timeout = "30m"

  depends_on = [time_sleep.wait_activate_apis]
}

resource "google_sql_user" "retool_database_user" {
  project = var.project_id

  instance = module.retool_database.instance_name

  name     = local.database_user
  password = data.google_secret_manager_secret_version.retool_database_password.secret_data
}
