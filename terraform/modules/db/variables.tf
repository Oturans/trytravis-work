#variable - mongodb
variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
variable zone {
  description = "Zone for VM"
  default     = "europe-west1-d"
}
variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable machine_type_db {
  description = "machine type for VM"
  default     = "g1-small"
}
variable private_key_path {
  description = "Path to the private key used for ssh access"
}
