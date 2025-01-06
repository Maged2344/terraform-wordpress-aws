terraform {
  backend "s3" {
    bucket = "maged-tf-state"
    key    = "terraform_state"
    region = "us-east-1"
  }
}