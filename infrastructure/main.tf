provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  default_service_account = "514230164013-compute@developer.gserviceaccount.com"
}

resource "google_compute_network" "vpc" {
  name = "hello-app-vpc"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "hello-app-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.name
}

resource "google_compute_instance" "vm" {
  name         = "hello-vm"
  machine_type = "f1-micro"
  zone         = var.zone

  tags = ["app-mysql-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork         = google_compute_subnetwork.subnet.name
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = file("provision_vm.sh")
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-traffic"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["app-server"]
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

resource "google_storage_bucket_iam_member" "terraform_state_admin" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:deployer@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "secret_accessor_mysql_password" {
  project = google_secret_manager_secret.mysql_password.project
  secret_id = google_secret_manager_secret.mysql_password.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:deployer@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "mysql_password_accessor" {
  project = google_secret_manager_secret.mysql_password.project
  secret_id = google_secret_manager_secret.mysql_password.secret_id
  role   = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.default_service_account}"
}

resource "google_secret_manager_secret" "mysql_password" {
  secret_id = "mysql-password"
  replication {
    user_managed {
      replicas {
          location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret" "mysql_root_password" {
  secret_id = "mysql-root-password"
  replication {
    user_managed {
      replicas {
          location = var.region
      }
    }
  }
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