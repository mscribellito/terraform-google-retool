// Create api service

module "retool_api" {
  source  = "GoogleCloudPlatform/cloud-run/google"
  version = "0.7.0"

  service_name = "retool-api"
  project_id   = var.project_id
  location     = var.region

  env_vars = concat(
    [{
      name  = "SERVICE_TYPE"
      value = "MAIN_BACKEND,DB_CONNECTOR"
    }],
    local.env_vars
  )

  env_secret_vars = flatten([
    for s in local.env_secret_vars : {
      name = s.name,
      value_from = [{
        secret_key_ref = {
          name = s.value_from,
        key = "latest" }
      }]
    }
  ])

  image = var.retool_image
  container_command = [
    "./docker_scripts/start_api.sh",
  ]

  ports = {
    "name" : "http1",
    "port" : 3000
  }

  limits = {
    cpu    = var.api_cpu
    memory = var.api_memory
  }

  members = ["allUsers"]

  service_account_email = module.retool_service_account.email

  template_annotations = {
    "autoscaling.knative.dev/minScale"      = var.api_min_instances
    "autoscaling.knative.dev/maxScale"      = var.api_max_instances
    "generated-by"                          = "terraform"
    "run.googleapis.com/client-name"        = "terraform"
    "run.googleapis.com/cloudsql-instances" = module.retool_database.instance_connection_name
  }

  template_labels = {
    "run.googleapis.com/startupProbeType" = "Default"
  }

  verified_domain_name = var.domain_name != null ? [var.domain_name] : []

  depends_on = [
    time_sleep.wait_activate_apis,
    google_cloud_run_v2_job.retool_jobs_runner
  ]
}

// Create jobs-runner job

resource "google_cloud_run_v2_job" "retool_jobs_runner" {
  project = var.project_id

  name     = "retool-jobs-runner"
  location = var.region

  template {

    template {

      containers {
        env {
          name  = "SERVICE_TYPE"
          value = "JOBS_RUNNER"
        }

        dynamic "env" {
          for_each = local.env_vars
          content {
            name  = env.value["name"]
            value = env.value["value"]
          }
        }

        dynamic "env" {
          for_each = local.env_secret_vars
          content {
            name = env.value["name"]
            value_source {
              secret_key_ref {
                secret  = env.value["value_from"]
                version = "latest"
              }
            }
          }
        }

        image = var.retool_image
        command = [
          "./docker_scripts/start_api.sh",
        ]

        resources {
          limits = {
            cpu    = var.jobs_runner_cpu
            memory = var.jobs_runner_memory
          }
        }

        volume_mounts {
          name       = "cloudsql"
          mount_path = "/cloudsql"
        }
      }

      volumes {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [module.retool_database.instance_connection_name]
        }
      }

      timeout     = "1800s"
      max_retries = 1

      service_account = module.retool_service_account.email

    }

  }

  depends_on = [time_sleep.wait_activate_apis]
}
