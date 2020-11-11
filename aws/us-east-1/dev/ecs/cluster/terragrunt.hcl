terraform {
  # source = "git::git@github.com:suharshan/infra-modules.git//ecs/cluster?ref=v0.0.1"
  source = "../../../../../../infra-modules/ecs/cluster"
}
inputs = {
  cluster_name = "dev"
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
