
#variable - reddit-app
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable zone {
  description = "Zone for VM"
  default     = "europe-west1-d"
}
variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  description = "Path to the private key used for ssh access"
}
variable machine_type_app {
  description = "machine type for VM"
  default     = "g1-small"
}
variable database_url {
  description = "database url"
  default     = "localhost"
}
