variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable zone {
  description = "Zone for VM"
  default     = "europe-west1-d"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}