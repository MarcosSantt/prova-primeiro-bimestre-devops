output "address" {
  description = "Hostname do RDS (sem a porta)"
  value       = aws_db_instance.postgres.address
}

output "port" {
  description = "Porta do PostgreSQL"
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "Nome do banco criado"
  value       = aws_db_instance.postgres.db_name
}

output "username" {
  description = "Usuário master do banco"
  value       = aws_db_instance.postgres.username
}

output "password" {
  description = "Senha master gerada (sensível: não aparece no plan/apply)"
  value       = random_password.db.result
  sensitive   = true
}
