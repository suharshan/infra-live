terraform {
  #source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//aws/modules/https-443"
  source = "../../../../../../../infra-modules/vpc/security_groups/http-80"
  # source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//aws/modules/https-443?ref=v3.16.0" 
}

dependency "vpc" {
  config_path = "../../vpcs/services-vpc"

  mock_outputs_allowed_terraform_commands = ["plan", "destroy"]
  mock_outputs = {
    vpc_id = "fake-vpc-id"
  }
}

inputs = {
  name = "signup-alb-dev"

  vpc_id = dependency.vpc.outputs.vpc_id
  ingress_cidr_blocks = [
    "0.0.0.0/0"
  ]

  # tags = {
  #   Name     = "${var.name}-external-alb-${var.env}"
  #   Env      = "${var.env}"
  #   Provider = "terraform"
  # }
}

include {
  path = find_in_parent_folders()
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
  provider "aws" {
    version = "3.14.0"
    profile = var.profile
    region  = var.region
  }
  EOF
}
