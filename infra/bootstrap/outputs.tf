output "bucket_name" {
  description = "Bucket a ser usado no backend \"s3\" do projeto principal"
  value       = aws_s3_bucket.tfstate.bucket
}

output "lock_table_name" {
  description = "Tabela a ser usada em dynamodb_table no backend"
  value       = aws_dynamodb_table.locks.name
}
