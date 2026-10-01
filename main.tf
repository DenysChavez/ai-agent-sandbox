terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"
}

module "iam" {
  source = "./modules/iam"
}

module "compute" {
  source = "./modules/compute"

  private_subnet_id     = module.network.private_subnet_id
  vpc_id                 = module.network.vpc_id
  instance_profile_name  = module.iam.instance_profile_name
}

module "storage" {
  source = "./modules/storage"

  ec2_role_arn = module.iam.role_arn
}

module "backup" {
  source = "./modules/backup"

  instance_arn = module.compute.instance_arn
}

module "monitoring" {
  source = "./modules/monitoring"

  alert_email = "dvchf26@gmail.com"
}
