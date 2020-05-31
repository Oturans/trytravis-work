terraform {
  # Версия terraform
  required_version = ">= 0.12.0"
}

provider "google" {
  version = ">= 2.15"
  project = var.project
  region  = var.region
}

resource "google_compute_project_metadata" "ssh-keys" {
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
  project = var.project
}

resource "google_compute_instance" "docker" {
  count        = var.ncount
  name         = "docker-machine-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["docker-machine"]
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    # путь до публичного ключа
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_docker" {
  name = "docker-machine-default"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["docker-machine"]
}

#---------------------------------------------------
resource "google_compute_firewall" "firewall_ssh" {
  name    = "docker-allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}
