terraform {
  backend "s3" {
    bucket = "phclark-terraform-state"
    key    = "environment/dev/terraform.tfstate"
    region = "us-east-1"
  }
}