data "google_client_config" "default" {}

resource "terracurl_request" "exec" {
  name   = "exec-job"
  url    = "https://run.googleapis.com/v2/${google_cloud_run_v2_job.retool_jobs_runner.id}:run"
  method = "POST"
  headers = {
    Authorization = "Bearer ${data.google_client_config.default.access_token}"
    Content-Type  = "application/json",
  }
  response_codes         = [200]
  destroy_url            = "https://run.googleapis.com/v2/${google_cloud_run_v2_job.retool_jobs_runner.id}"
  destroy_method         = "GET"
  destroy_response_codes = [200]
  destroy_headers = {
    Authorization = "Bearer ${data.google_client_config.default.access_token}"
    Content-Type  = "application/json",
  }

  lifecycle {
    ignore_changes = [
      headers,
      destroy_headers
    ]
  }
}
