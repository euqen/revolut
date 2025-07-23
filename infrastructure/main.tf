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
    access_config {} # Needed for SSH access only
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update && apt-get install -y docker.io

    docker network create data

    docker run -d \
      --name mysql \
      --network database_network \
      -e MYSQL_ROOT_PASSWORD=${var.mysql_root_password} \
      -e MYSQL_DATABASE=${var.mysql_database} \
      -e MYSQL_USER=${var.mysql_user} \
      -e MYSQL_PASSWORD=${var.mysql_password} \
      mysql:8.0.33
  EOF
}

# Firewall rules - only allow health checks & LB traffic
resource "google_compute_firewall" "allow_lb" {
  name    = "allow-lb-traffic"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = [var.app_port]
  }

  source_ranges = [
    "35.191.0.0/16",   # GCP LB ranges
    "130.211.0.0/22"
  ]

  target_tags = ["app-server"]
}

# Health check
resource "google_compute_health_check" "http" {
  name = "http-health-check"
  http_health_check {
    port        = var.app_port
    request_path = "/"
  }
}

# Instance group with single instance
resource "google_compute_instance_group" "app_group" {
  name      = "app-group"
  zone      = var.zone
  instances = [google_compute_instance.vm.self_link]

  named_port {
    name = "http"
    port = var.app_port
  }
}

# Backend service
resource "google_compute_backend_service" "backend" {
  name          = "app-backend"
  protocol      = "HTTP"
  port_name     = "http"
  timeout_sec   = 10
  health_checks = [google_compute_health_check.http.self_link]

  backend {
    group = google_compute_instance_group.app_group.self_link
  }
}

# URL map
resource "google_compute_url_map" "url_map" {
  name            = "app-url-map"
  default_service = google_compute_backend_service.backend.self_link
}

# HTTP proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "app-http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

# Global forwarding rule (public IP)
resource "google_compute_global_forwarding_rule" "http_rule" {
  name       = "http-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.self_link
  port_range = "80"
  ip_protocol = "TCP"
}

resource "google_compute_global_address" "lb_ip" {
  name = "lb-ip"
}

variable "project_id" { default = "just-vent-235315" }
variable "region" { default = "europe-west1" }
variable "zone" { default = "europe-west1-b" }
variable "mysql_root_password" {}
variable "mysql_database" { default = "hello_app_db"}
variable "mysql_user" { default = "hello_app_user"}
variable "mysql_password" {}
variable "app_port" { default = "3000"}

output "vm_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "load_balancer_ip" {
  value = google_compute_global_forwarding_rule.http_rule.ip_address
}
