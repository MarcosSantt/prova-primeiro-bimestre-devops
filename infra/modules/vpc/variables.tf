variable "nome" {
  description = "Prefixo usado no nome dos recursos (ex.: technova-prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "Faixa de IPs da VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Subnets públicas, uma por zona de disponibilidade"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Subnets privadas, uma por zona de disponibilidade"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "O RDS exige pelo menos duas subnets privadas (em AZs diferentes)."
  }
}
