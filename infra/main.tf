# Composição dos módulos: o output de um alimenta o input do próximo
#   vpc ──> security-group ──> rds ──> ec2

locals {
  nome = "technova-${var.ambiente}"
}

module "vpc" {
  source = "./modules/vpc"

  nome                 = local.nome
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_group" {
  source = "./modules/security-group"

  nome             = local.nome
  vpc_id           = module.vpc.vpc_id
  ssh_allowed_cidr = var.ssh_allowed_cidr
  api_port         = var.api_port
}

module "rds" {
  source = "./modules/rds"

  nome               = local.nome
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_group.rds_sg_id]
  instance_class     = var.db_instance_class
  db_name            = var.db_name
  db_username        = var.db_username
}

module "ec2" {
  source = "./modules/ec2"

  nome               = local.nome
  instance_type      = var.instance_type
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.security_group.ec2_sg_id]
  key_name           = var.key_name

  repo_url    = var.repo_url
  repo_branch = var.repo_branch
  api_port    = var.api_port

  db_host     = module.rds.address
  db_port     = module.rds.port
  db_name     = module.rds.db_name
  db_user     = module.rds.username
  db_password = module.rds.password
}
