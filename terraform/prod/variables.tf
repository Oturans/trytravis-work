variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}
variable "private_key_path" {
  # Описание переменной
  description = "Path to the private key used for connection provisioner"
}
variable zone {
  description = "Zone for VM"
  default     = "europe-west1-d"
}
variable ncount {
  description = "Count for VM"
  default     = "1"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}

variable machine_type_app {
  description = "machine type for VM"
  default     = "g1-small"
}
variable machine_type_db {
  description = "machine type for VM"
  default     = "g1-small"
}
variable database_url {
  description = "database url"
  default     = "localhost"
}
