output "api_url" {
  description = "URL pública da API de reservas"
  value       = "http://${module.ec2.public_ip}:${var.api_port}"
}

output "api_health_url" {
  description = "Healthcheck da API (verifica também a conexão com o RDS)"
  value       = "http://${module.ec2.public_ip}:${var.api_port}/health"
}

output "ec2_public_ip" {
  description = "IP público da EC2 (SSH: ssh -i labsuser.pem ec2-user@<ip>)"
  value       = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "Endpoint do RDS (acessível só de dentro da VPC)"
  value       = module.rds.address
}

output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}
