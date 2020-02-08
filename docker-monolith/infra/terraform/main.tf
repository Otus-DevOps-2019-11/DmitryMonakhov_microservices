provider "google" {
  version = "~> 2.15"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "docker-host" {
  count        = var.node_count
  name         = "reddit-docker-host-${count.index + 1}"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-docker-host"]
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
