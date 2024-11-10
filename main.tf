provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "printhubgh-terraform-state-bucket"  # Replace with your S3 bucket name
    key            = "printhub/jupiter/terraform.tfstate" # The path within the bucket to store the state file. You can structure it according to your project.
    region         = "us-east-1"                          # Region where the S3 bucket is located
    dynamodb_table = "printhubgh-terraform-lock-table"    # DynamoDB table for state locking
    encrypt        = true                                 # Encrypt state file using S3 default encryption
  }
}

module "vpc" {
  source                        = "./vpc"
  vpc_cidr_block                = var.vpc_cidr_block
  tags                          = local.project_tags
  frontend_cidr_block           = var.frontend_cider_block
  backend_cidr_block            = var.backend_cider_block
  availability_zone             = var.availability_zone
  db_cidr_block                 = var.db_cidr_block
  apci_frontend_subnet_az_1a_id = module.vpc.apci_frontend_subnet_az_1a_id
  apci_frontend_subnet_az_1b_id = module.vpc.apci_frontend_subnet_az_1b_id

}
module "alb" {
  source                        = "./alb"
  ssl_policy                    = var.ssl_policy
  certificate_arn               = var.certificate_arn
  vpc_id                        = module.vpc.vpc_id
  zone_id                       = var.zone_id
  tags                          = local.project_tags
  apci_frontend_subnet_az_1a_id = module.vpc.apci_frontend_subnet_az_1a_id
  apci_frontend_subnet_az_1b_id = module.vpc.apci_frontend_subnet_az_1b_id

}

module "auto-scaling" {
  source                        = "./auto-scaling"
  key_name                      = var.key_name
  tags                          = local.project_tags
  instance_type                 = var.instance_type
  alb_security_group_id         = module.alb.alb_security_group_id
  image_id                      = var.image_id
  target_group_arn              = module.alb.target_group_arn
  vpc_id                        = module.vpc.vpc_id
  apci_frontend_subnet_az_1a_id = module.vpc.apci_frontend_subnet_az_1a_id
  apci_frontend_subnet_az_1b_id = module.vpc.apci_frontend_subnet_az_1b_id

}

module "route53" {
  source          = "./route53"
  alb_dns_name    = module.alb.alb_dns_name
  zone_id         = var.zone_id
  dns_name        = var.dns_name
  alb_zone_id     = module.alb.alb_zone_id
  certificate_arn = var.certificate_arn
}

module "ec2" {
  source                        = "./ec2"
  instance_type                 = var.instance_type
  apci_frontend_subnet_az_1a_id = module.vpc.apci_frontend_subnet_az_1a_id
  apci_backend_subnet_az_1a_id  = module.vpc.apci_backend_subnet_az_1a_id
  apci_backend_subnet_az_1b_id  = module.vpc.apci_backend_subnet_az_1b_id
  key_name                      = var.key_name
  vpc_id                        = module.vpc.vpc_id
  image_id                      = var.image_id
  tags                          = local.project_tags
}

module "rds" {
  source                  = "./rds"
  vpc_id                  = module.vpc.vpc_id
  db_instance_type        = var.db_instance_type
  apci_db_subnet_az_1a_id = module.vpc.apci_db_subnet_az_1a_id
  apci_db_subnet_az_1b_id = module.vpc.apci_db_subnet_az_1b_id
  password                = var.password
  username                = var.username
  tags                    = local.project_tags
  vpc_cidr_block          = var.vpc_cidr_block
  engine_version          = var.engine_version
}