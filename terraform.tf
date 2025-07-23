variable "project_id" { default = "just-vent-235315" }
variable "region" { default = "europe-west1" }
variable "app_port" { default = "3000"}
variable "docker_registry_host" { default = "europe-west1-docker.pkg.dev" }
variable "image" { default = "revolut-hello/app" }
variable "git_hash_image_version" { default = "123123" }

 provider "google" {
    project = "${var.project_id}"
  }

  resource "google_cloud_run_v2_service" "revolut_hello_app" {
    name     = "revolut-hello"
    location = "europe-west1"
    client   = "terraform"

    template {
      containers {
        image = "${var.docker_registry_host}/${var.project_id}/${var.image}:${var.git_hash_image_version}"

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
        env {
            name = "PORT"
            value = "3000"
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