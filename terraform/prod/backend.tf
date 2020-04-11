# data "terraform_remote_state" "foo" {
#   backend = "gcs"
#   config = {
#     bucket = "storage-bucket-oturans"
#     prefix = "prod"
#   }
# }

terraform {
  backend "gcs" {
    bucket = "storage-bucket-oturans"
    prefix = "terraform/prod"
  }
}