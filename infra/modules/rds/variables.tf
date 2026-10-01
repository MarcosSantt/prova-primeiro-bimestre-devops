variable "nome" {
  description = "Prefixo usado no nome dos recursos (ex.: technova-prod)"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas do DB subnet group (output do módulo vpc)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups do RDS (output do módulo security-group)"
  type        = list(string)
}

variable "engine_version" {
  description = "Versão major do PostgreSQL"
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "Classe da instância RDS (Learner Lab aceita até medium)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nome do banco de dados da aplicação"
  type        = string
}

variable "db_username" {
  description = "Usuário master do PostgreSQL"
  type        = string
}
