terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-alb.git?ref=v5.9.0"
}

dependency "vpc" {
  config_path = "../../../../vpc/vpcs/services-vpc"

  mock_outputs_allowed_terraform_commands = ["plan", "destroy"]
  mock_outputs = {
    vpc_id = "fake-vpc-id",
    public_subnets = [
      "10.0.101.0/24",
      "10.0.102.0/24",
      "10.0.103.0/24"
    ]
  }
}

dependency "sg" {
  config_path = "../../../../vpc/security_groups/signup-alb"

  mock_outputs_allowed_terraform_commands = ["plan", "destroy"]
  mock_outputs = {
    this_security_group_id = "fake-this_security_group_id"
  }
}

inputs = {
  load_balancer_type = "application"

  vpc_id = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.public_subnets
  security_groups = ["${dependency.sg.outputs.this_security_group_id}"]

  target_groups = [
    {
      name      = "signup"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]

  http_tcp_listeners = [
    {
      port = 80
      protocol = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Name     = "signup"
    Env      = "dev"
    Provider = "terraform"
  }
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
