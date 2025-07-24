variable "project_id" { default = "just-vent-235315" }
variable "region" { default = "europe-west1" }
variable "app_port" { default = "3000"}
variable "docker_registry_host" { default = "europe-west1-docker.pkg.dev" }
variable "image" { default = "revolut-hello/app" }
variable "git_hash_image_version" { default = "123123" }

terraform {
  backend "gcs" {
    bucket = "terraform-state-revolut-hometask"
    prefix = "terraform/state"
  }
}

 provider "google" {
    project = "${var.project_id}"
  }

  resource "google_cloud_run_v2_service" "revolut_hello_app" {
    name     = "revolut-hello"
    location = "europe-west1"
    client   = "terraform"

    deletion_protection = false

    template {
      scaling {
        min_instance_count = 1
        max_instance_count = 2
      }

      containers {
        image = "${var.docker_registry_host}/${var.project_id}/${var.image}:${var.git_hash_image_version}"

        startup_probe {
          timeout_seconds = 10
          period_seconds = 10
          failure_threshold = 3
          initial_delay_seconds = 5

          http_get {
            path = "/healthz/liveness"
          }
        }

        liveness_probe {
          timeout_seconds = 10
          period_seconds = 10
          failure_threshold = 3
          
          http_get {
            path = "/healthz/readiness"
          }
        }

        env {
          name = "MYSQL_ROOT_PASSWORD"
          value = "XXXXXX"
        }

        env {
          name = "MYSQL_DATABASE"
          value = "app_Db"
        }

        env {
          name = "MYSQL_USER"
          value = "app_user"
        }
      }
    }

  }

  resource "google_cloud_run_v2_service_iam_member" "noauth" {
    location = google_cloud_run_v2_service.revolut_hello_app.location
    name     = google_cloud_run_v2_service.revolut_hello_app.name
    role     = "roles/run.invoker"
    member   = "allUsers"
  }