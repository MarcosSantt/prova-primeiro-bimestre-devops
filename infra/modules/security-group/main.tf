# ===== Security Group da EC2 (API) =====
resource "aws_security_group" "ec2" {
  name        = "${var.nome}-api-sg"
  description = "Acesso HTTP publico a API e SSH restrito"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.nome}-api-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_api" {
  security_group_id = aws_security_group.ec2.id
  description       = "Porta da API"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = var.api_port
  to_port           = var.api_port
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  security_group_id = aws_security_group.ec2.id
  description       = "SSH apenas do IP do administrador"
  cidr_ipv4         = var.ssh_allowed_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

# Saída liberada: a EC2 precisa baixar pacotes, clonar o repo e falar com o RDS
resource "aws_vpc_security_group_egress_rule" "ec2_saida" {
  security_group_id = aws_security_group.ec2.id
  description       = "Saida liberada"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ===== Security Group do RDS =====
resource "aws_security_group" "rds" {
  name        = "${var.nome}-db-sg"
  description = "PostgreSQL acessivel somente pela API"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.nome}-db-sg"
  }
}

# Origem é o SG da EC2, não um IP: só instâncias com esse SG chegam ao banco
resource "aws_vpc_security_group_ingress_rule" "rds_postgres" {
  security_group_id            = aws_security_group.rds.id
  description                  = "PostgreSQL vindo da API"
  referenced_security_group_id = aws_security_group.ec2.id
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
}
