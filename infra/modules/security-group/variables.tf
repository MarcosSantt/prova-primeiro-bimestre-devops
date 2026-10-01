variable "nome" {
  description = "Prefixo usado no nome dos recursos (ex.: technova-prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC onde os security groups serão criados (output do módulo vpc)"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "IP liberado para SSH na EC2, no formato x.x.x.x/32"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0)) && var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "Informe um CIDR válido e restrito (ex.: 200.100.50.25/32), nunca 0.0.0.0/0."
  }
}

variable "api_port" {
  description = "Porta em que a API fica exposta na EC2"
  type        = number
  default     = 3000
}

variable "db_port" {
  description = "Porta do PostgreSQL"
  type        = number
  default     = 5432
}
