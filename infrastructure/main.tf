provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  default_service_account = "514230164013-compute@developer.gserviceaccount.com"
}

resource "google_compute_network" "revolut_hello_app_network" {
  name = "revolut-hello-app-network"
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.revolut_hello_app_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.revolut_hello_app_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region
  repository_id = "revolut-hello"
  format        = "DOCKER"
}

resource "google_storage_bucket" "terraform_state" {
  name = "terraform-state-revolut-hometask"
  location = var.region
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }
}

resource "google_sql_database_instance" "revolut_hello_app_db" {
  name = "revolut-hello-app-db-0"
  region = var.region
  database_version = "MYSQL_8_0"


  settings {
    tier = "db-g1-small"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.revolut_hello_app_network.self_link
      enable_private_path_for_google_cloud_services = true
    }
    backup_configuration {
      enabled = true
    }
  }

 depends_on = [google_service_networking_connection.private_vpc_connection]
}

module "deployer_sa" {
  source  = "terraform-google-modules/service-accounts/google//modules/simple-sa"
  version = "~> 4.0"

  project_id = var.project_id
  name       = "deployer"
  project_roles = [
    "roles/artifactregistry.writer",
    "roles/run.admin",
    "roles/iam.serviceAccountUser"
  ]
}

resource "google_storage_bucket" "revolut_hello_app_bucket" {
  name     = "revolut-hello-app-sqlite-storage"
  location = var.region
}

resource "google_storage_bucket_iam_member" "revolut_hello_app_bucket_admin" {
  bucket = google_storage_bucket.revolut_hello_app_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:deployer@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "terraform_state_admin" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:deployer@${var.project_id}.iam.gserviceaccount.com"
}

variable "project_id" { default = "just-vent-235315" }
variable "region" { default = "europe-west1" }
variable "zone" { default = "europe-west1-b" }