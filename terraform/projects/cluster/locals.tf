locals {
    tags = {
        Terraform = "true"
        ControlledBy = "Terraform"
        environment = var.environment
    }
}