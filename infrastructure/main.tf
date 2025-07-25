provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  default_service_account = "514230164013-compute@developer.gserviceaccount.com"
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
variable "app_port" { default = "3000"}
variable "ssh_public_key_path" { default = "~/.ssh/id_rsa.pub" }
variable "ssh_user" { default = "euqen" }

output "vm_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}