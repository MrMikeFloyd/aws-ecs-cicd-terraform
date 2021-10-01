# ---------------------------------------------------------------------------------------------------------------------
# AWS PROVIDER FOR TF CLOUD
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = "~>0.14"
  backend "s3" {
    # Setting variables in the backend section isn't possible as of now, see https://github.com/hashicorp/terraform/issues/13022
    bucket = "terraform-backend-state-cc-cloud-bootstrap"
    # TODO: Investigate how to set dynamically
    encrypt = true
    dynamodb_table = "terraform-backend-lock-cc-cloud-bootstrap"
    # TODO: Investigate how to set dynamically
    key = "terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

module "cicd" {
  source = "./modules/cicd"
  project = var.project
  stack = var.stack
  aws_region = var.aws_region
  image_repo_name = var.image_repo_name
  source_repo_branch = var.source_repo_branch
  source_repo_name = var.source_repo_name
  family = var.family
}

module "compute" {
  source = "./modules/compute"
  project = var.project
  stack = var.stack
  aws_region = var.aws_region
  aws_ecr = var.aws_ecr
  fargate-task-service-role = var.fargate-task-service-role
}

module "network" {
  source = "./modules/network"
  project = var.project
  stack = var.stack
  az_count = var.az_count
  vpc_cidr = var.vpc_cidr
}