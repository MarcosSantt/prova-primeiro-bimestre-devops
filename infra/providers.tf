# Projeto principal da infraestrutura (VPC + EC2 + RDS)
# O state fica no bucket S3 criado em infra/bootstrap, com lock no DynamoDB.

terraform {
  required_version = ">= 1.5"

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

  # Backend não aceita variáveis: os valores vêm dos outputs do bootstrap
  backend "s3" {
    bucket         = "technova-tfstate-6325127"
    key            = "technova/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "technova-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  # Tags aplicadas automaticamente em todos os recursos deste projeto
  default_tags {
    tags = {
      Projeto       = "technova-reservas"
      Ambiente      = var.ambiente
      GerenciadoPor = "terraform"
      Responsavel   = var.responsavel
    }
  }
}
