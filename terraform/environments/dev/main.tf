provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "../../modules/vpc"
  cidr_block           = var.vpc_cidr
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
}

module "iam" {
  source = "../../modules/iam"
}

module "ec2" {
  source             = "../../modules/ec2"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  subnet_id          = module.vpc.public_subnets[0]
  vpc_id             = module.vpc.vpc_id
  dockerhub_username = var.dockerhub_username
  dockerhub_password = var.dockerhub_password
  key_name           = var.key_name
}

module "alb" {
  source     = "../../modules/alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
}
