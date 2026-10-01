output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.api.id
}

output "public_ip" {
  description = "IP público da EC2"
  value       = aws_instance.api.public_ip
}
