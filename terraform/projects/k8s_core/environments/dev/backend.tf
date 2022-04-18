terraform {
  backend "s3" {
    bucket = "phclark-terraform-state"
    key    = "ingress/dev/terraform.tfstate"
    region = "us-east-1"
  }
}


data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "phclark-terraform-state"
    key    = "cluster/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
