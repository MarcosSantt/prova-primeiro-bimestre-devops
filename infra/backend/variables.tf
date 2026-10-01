variable "aws_region" {
  description = "Região da AWS (Learner Lab só permite us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nome do bucket do state (precisa ser único no mundo todo)"
  type        = string
  default     = "technova-tfstate-6325127"
}

variable "lock_table_name" {
  description = "Nome da tabela DynamoDB usada para lock do state"
  type        = string
  default     = "technova-terraform-locks"
}

variable "responsavel" {
  description = "RA do aluno responsável, usado nas tags"
  type        = string
  default     = "6325127"
}
