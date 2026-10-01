# Duas zonas de disponibilidade da região (o RDS exige subnets em 2 AZs)
data "aws_availability_zones" "disponiveis" {
  state = "available"
}

# ===== VPC =====
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true # necessário para resolver o endpoint do RDS

  tags = {
    Name = "${var.nome}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.nome}-igw"
  }
}

# ===== Subnets públicas (EC2 da API) =====
resource "aws_subnet" "publica" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.disponiveis.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.nome}-publica-${count.index + 1}"
  }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.main.id

  # Tudo que não é da VPC sai pelo Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.nome}-rt-publica"
  }
}

resource "aws_route_table_association" "publica" {
  count = length(aws_subnet.publica)

  subnet_id      = aws_subnet.publica[count.index].id
  route_table_id = aws_route_table.publica.id
}

# ===== Subnets privadas (RDS) =====
# Sem rota para a internet: o banco só é alcançável de dentro da VPC
resource "aws_subnet" "privada" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.disponiveis.names[count.index]

  tags = {
    Name = "${var.nome}-privada-${count.index + 1}"
  }
}

resource "aws_route_table" "privada" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.nome}-rt-privada"
  }
}

resource "aws_route_table_association" "privada" {
  count = length(aws_subnet.privada)

  subnet_id      = aws_subnet.privada[count.index].id
  route_table_id = aws_route_table.privada.id
}
