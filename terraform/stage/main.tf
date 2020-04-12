terraform {
  # Версия terraform
  required_version = ">= 0.12.0"

}
provider "google" {
  # Версия провайдера
  version = "~> 2.15"
  # ID проекта
  project = var.project
  region  = var.region
}

resource "google_compute_project_metadata" "ssh-keys" {
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}appuser1:${file(var.public_key_path)}appuser2:${file(var.public_key_path)}"
  }
  project = var.project
}

module "app" {
  source           = "../modules/app"
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  zone             = var.zone
  app_disk_image   = var.app_disk_image
  machine_type_app = var.machine_type_app
  database_url     = module.db.db_internal_ip
}

module "db" {
  source           = "../modules/db"
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  zone             = var.zone
  db_disk_image    = var.db_disk_image
  machine_type_db  = var.machine_type_db
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["0.0.0.0/0"]
}
