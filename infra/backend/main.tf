# ===== Bucket S3 que guarda o terraform.tfstate =====
resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_name

  # Permite o terraform destroy apagar o bucket mesmo com versões dentro
  # (necessário no Learner Lab para limpar tudo no fim)
  force_destroy = true

  tags = {
    Name = var.bucket_name
  }
}

# Versionamento: cada apply gera uma nova versão do state (dá para voltar atrás)
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encriptação server-side: o state pode conter senhas (ex.: senha do RDS)
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloqueia qualquer acesso público ao bucket
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ===== Tabela DynamoDB para lock =====
# Impede dois "terraform apply" ao mesmo tempo escrevendo no mesmo state
resource "aws_dynamodb_table" "locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = var.lock_table_name
  }
}
