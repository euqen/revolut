provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
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

  tags = ["app-server"]

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
    ssh-keys = "euqen:${file("~/.ssh/id_ed25519.pub")}"
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

resource "google_storage_bucket_iam_member" "terraform_state_admin" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.admin"
  member = "serviceAccount:github-gcr-pull@${var.project_id}.iam.gserviceaccount.com"
}


variable "project_id" { default = "just-vent-235315" }
variable "region" { default = "europe-west1" }
variable "zone" { default = "europe-west1-b" }
variable "app_port" { default = "3000"}
variable "private_key_path" { default = "~/.ssh/id_rsa" }

output "vm_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}