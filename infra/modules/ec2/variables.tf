variable "nome" {
  description = "Prefixo usado no nome dos recursos (ex.: technova-prod)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet pública onde a EC2 será criada (output do módulo vpc)"
  type        = string
}

variable "security_group_ids" {
  description = "Security groups da EC2 (output do módulo security-group)"
  type        = list(string)
}

variable "key_name" {
  description = "Key pair para SSH (o Learner Lab já fornece a vockey)"
  type        = string
  default     = "vockey"
}

variable "instance_profile" {
  description = "Instance profile pré-existente do Learner Lab (não é possível criar IAM)"
  type        = string
  default     = "LabInstanceProfile"
}

# ===== Aplicação =====
variable "repo_url" {
  description = "Repositório Git clonado pela EC2 para buildar a imagem da API"
  type        = string
}

variable "repo_branch" {
  description = "Branch do repositório usada no deploy"
  type        = string
  default     = "main"
}

variable "api_port" {
  description = "Porta da EC2 que encaminha para a porta 3000 do container"
  type        = number
  default     = 3000
}

# ===== Conexão com o banco (outputs do módulo rds) =====
variable "db_host" {
  description = "Hostname do RDS"
  type        = string
}

variable "db_port" {
  description = "Porta do PostgreSQL"
  type        = number
}

variable "db_name" {
  description = "Nome do banco da aplicação"
  type        = string
}

variable "db_user" {
  description = "Usuário do banco"
  type        = string
}

variable "db_password" {
  description = "Senha do banco"
  type        = string
  sensitive   = true
}
