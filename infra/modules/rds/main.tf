# Senha gerada pelo Terraform: não aparece no código nem no Git
# (fica só no state, que está encriptado no S3)
resource "random_password" "db" {
  length  = 24
  special = true
  # RDS não aceita / @ " e espaço na senha master
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.nome}-db-subnets"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.nome}-db-subnets"
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.nome}-postgres"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1

  # Ambiente de laboratório: permite destruir sem snapshot final
  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately   = true

  tags = {
    Name = "${var.nome}-postgres"
  }
}
