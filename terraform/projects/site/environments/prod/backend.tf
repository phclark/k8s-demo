terraform {
  backend "s3" {
    bucket = "phclark-terraform-state"
    key    = "site/prod/terraform.tfstate"
    region = "us-east-1"
  }
}