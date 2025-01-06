terraform {
  backend "s3" {
    bucket = "maged-tf-state"
    key    = "terraform_state"
    region = "us-east-1"
  }
}

# terraform {
#   required_providers {
#     cloudflare = {
#       source  = "cloudflare/cloudflare"
#       version = "~> 4.0"
#     }
#   }

 
#   backend "s3" {
#     bucket = "maged-tf-state"
#     key    = "terraform_state"
#     region = "us-east-1"
#   }
# }
# # provider "cloudflare" {
# #   api_token = var.cloudflare_api_token
# # }