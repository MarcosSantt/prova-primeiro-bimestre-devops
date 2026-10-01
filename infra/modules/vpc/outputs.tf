output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas (usadas pela EC2)"
  value       = aws_subnet.publica[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas (usadas pelo RDS)"
  value       = aws_subnet.privada[*].id
}
