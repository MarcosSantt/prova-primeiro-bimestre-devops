output "api_url" {
  description = "URL pública da API de reservas"
  value       = "http://${aws_instance.api.public_ip}"
}

output "api_health_url" {
  description = "Healthcheck da API (verifica também a conexão com o RDS)"
  value       = "http://${aws_instance.api.public_ip}/health"
}

output "ec2_public_ip" {
  description = "IP público da EC2 (SSH: ssh -i labsuser.pem ec2-user@<ip>)"
  value       = aws_instance.api.public_ip
}

output "rds_endpoint" {
  description = "Endpoint do RDS (acessível só de dentro da VPC)"
  value       = aws_db_instance.postgres.address
}

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}
