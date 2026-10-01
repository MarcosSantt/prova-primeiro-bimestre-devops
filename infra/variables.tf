variable "aws_region" {
  description = "Região da AWS (Learner Lab só permite us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "ambiente" {
  description = "Nome do ambiente, usado nos nomes e tags dos recursos"
  type        = string
  default     = "prod"
}

variable "responsavel" {
  description = "RA do aluno responsável, usado nas tags"
  type        = string
  default     = "6325127"
}

# ===== Rede =====
variable "vpc_cidr" {
  description = "Faixa de IPs da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Subnets públicas (EC2), uma por zona de disponibilidade"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Subnets privadas (RDS), uma por zona; o RDS exige pelo menos duas zonas"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "ssh_allowed_cidr" {
  description = "IP liberado para SSH na EC2, no formato x.x.x.x/32 (seu IP público)"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0)) && var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "Informe um CIDR válido e restrito (ex.: 200.100.50.25/32), nunca 0.0.0.0/0."
  }
}

# ===== EC2 =====
variable "instance_type" {
  description = "Tipo da instância EC2 da API (a prova pede t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "api_port" {
  description = "Porta pública da API na EC2 (liberada no security group)"
  type        = number
  default     = 3000
}

variable "key_name" {
  description = "Key pair para SSH (o Learner Lab já fornece a vockey)"
  type        = string
  default     = "vockey"
}

variable "repo_url" {
  description = "Repositório Git clonado pela EC2 para buildar a imagem da API"
  type        = string
  default     = "https://github.com/MarcosSantt/prova-primeiro-bimestre-devops.git"
}

variable "repo_branch" {
  description = "Branch do repositório usada no deploy"
  type        = string
  default     = "main"
}

# ===== RDS =====
variable "db_instance_class" {
  description = "Classe da instância RDS (Learner Lab aceita até medium)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nome do banco de dados da aplicação"
  type        = string
  default     = "reservas"
}

variable "db_username" {
  description = "Usuário master do PostgreSQL"
  type        = string
  default     = "technova"
}
