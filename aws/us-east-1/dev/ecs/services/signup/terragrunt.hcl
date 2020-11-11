terraform {
  # source = "git::git@github.com:suharshan/infra-modules.git//ecs/cluster?ref=v0.0.1"
  source = "../../../../../../../infra-modules/ecs/service"
}

dependency "cluster" {
  config_path = "../../cluster"

  mock_outputs_allowed_terraform_commands = ["plan", "destroy"]
  mock_outputs = {
    cluster_id = "fake-cluster-id"
  }
}

dependency "alb" {
  config_path = "../../../load_balancers/alb/external/signup"

  mock_outputs_allowed_terraform_commands = ["plan", "destroy"]
  mock_outputs = {
    target_group_arns = [
      "arn:aws:elasticloadbalancing:us-east-1:123456789123:targetgroup/fake-target/8745097865346534"
    ]
  }
}

dependency "vpc" {
  config_path = "../../../vpc/vpcs/services-vpc"

  mock_outputs_allowed_terraform_commands = ["plan", "destroy"]
  mock_outputs = {
    vpc_id = "fake-vpc-id",
    private_subnets = [
      "10.0.101.0/24",
      "10.0.102.0/24",
      "10.0.103.0/24"
    ]
  }
}

dependency "sg" {
  config_path = "../../../vpc/security_groups/signup-alb"

  mock_outputs_allowed_terraform_commands = ["plan", "destroy"]
  mock_outputs = {
    this_security_group_id = "fake-this_security_group_id"
  }
}

inputs = {
  environment = "dev"
  name = "signup"
  cluster_id = dependency.cluster.outputs.cluster_id
  ecs_service_desired_count = 1
  ecs_service_deployment_maximum_percent = 200
  ecs_service_deployment_minimum_healthy_percent = 50
  container_port = 80
  target_group_arn = element(dependency.alb.outputs.target_group_arns, 0)

  container_name = "signup"

  vpc_id = dependency.vpc.outputs.vpc_id
  alb_security_group_id = dependency.sg.outputs.this_security_group_id
  private_subnet_ids = dependency.vpc.outputs.private_subnets
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
