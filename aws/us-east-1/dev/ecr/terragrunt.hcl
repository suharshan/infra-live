terraform {
  #source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//aws/modules/https-443"
  source = "../../../../../infra-modules/ecr"
  # source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//aws/modules/https-443?ref=v3.16.0" 
}

dependency "service" {
  config_path = "../ecs/services/signup"

  mock_outputs_allowed_terraform_commands = ["plan", "destroy"]
  mock_outputs = {
    service_name = "fake-service-name"
  }
}

inputs = {
  name = dependency.service.outputs.service_name

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
