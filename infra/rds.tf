# Senha gerada pelo Terraform: não aparece no código nem no Git
# (fica só no state, que está encriptado no S3)
resource "random_password" "db" {
  length  = 24
  special = true
  # RDS não aceita / @ " e espaço na senha master
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.nome}-db-subnets"
  subnet_ids = aws_subnet.privada[*].id

  tags = {
    Name = "${local.nome}-db-subnets"
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "${local.nome}-postgres"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1

  # Ambiente de laboratório: permite destruir sem snapshot final
  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately   = true

  tags = {
    Name = "${local.nome}-postgres"
  }
}
