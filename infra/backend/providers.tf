# Bootstrap do state remoto
# Este projeto usa state LOCAL de propósito: ele cria o bucket S3 e a tabela
# DynamoDB que o projeto principal (infra/) vai usar como backend.
# (problema do "ovo e da galinha": o backend precisa existir antes)

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Tags aplicadas automaticamente em todos os recursos deste projeto
  default_tags {
    tags = {
      Projeto       = "technova-reservas"
      Ambiente      = "bootstrap"
      GerenciadoPor = "terraform"
      Responsavel   = var.responsavel
    }
  }
}
