# ===== Security Group da API (EC2) =====
resource "aws_security_group" "api" {
  name        = "${local.nome}-api-sg"
  description = "Acesso HTTP publico a API e SSH restrito"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.nome}-api-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "api_http" {
  security_group_id = aws_security_group.api.id
  description       = "HTTP da API"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "api_ssh" {
  security_group_id = aws_security_group.api.id
  description       = "SSH apenas do IP do administrador"
  cidr_ipv4         = var.ssh_allowed_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

# Saída liberada: a EC2 precisa baixar pacotes, clonar o repo e falar com o RDS
resource "aws_vpc_security_group_egress_rule" "api_saida" {
  security_group_id = aws_security_group.api.id
  description       = "Saida liberada"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ===== Security Group do banco (RDS) =====
resource "aws_security_group" "db" {
  name        = "${local.nome}-db-sg"
  description = "PostgreSQL acessivel somente pela API"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.nome}-db-sg"
  }
}

# Origem é o SG da API, não um IP: só instâncias com esse SG chegam ao banco
resource "aws_vpc_security_group_ingress_rule" "db_postgres" {
  security_group_id            = aws_security_group.db.id
  description                  = "PostgreSQL vindo da API"
  referenced_security_group_id = aws_security_group.api.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
