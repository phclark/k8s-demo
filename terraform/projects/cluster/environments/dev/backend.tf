terraform {
  backend "s3" {
    bucket = "phclark-terraform-state"
    key    = "cluster/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
