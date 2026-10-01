# Refatoração para módulos: a primeira versão tinha todos os recursos na raiz.
# Os blocos "moved" dizem ao Terraform que o recurso só mudou de endereço,
# evitando destruir e recriar a VPC e o RDS (que já guardam dados).

# ----- vpc -----
moved {
  from = aws_vpc.main
  to   = module.vpc.aws_vpc.main
}

moved {
  from = aws_internet_gateway.main
  to   = module.vpc.aws_internet_gateway.main
}

moved {
  from = aws_subnet.publica
  to   = module.vpc.aws_subnet.publica
}

moved {
  from = aws_route_table.publica
  to   = module.vpc.aws_route_table.publica
}

moved {
  from = aws_route_table_association.publica
  to   = module.vpc.aws_route_table_association.publica
}

moved {
  from = aws_subnet.privada
  to   = module.vpc.aws_subnet.privada
}

moved {
  from = aws_route_table.privada
  to   = module.vpc.aws_route_table.privada
}

moved {
  from = aws_route_table_association.privada
  to   = module.vpc.aws_route_table_association.privada
}

# ----- security-group -----
moved {
  from = aws_security_group.api
  to   = module.security_group.aws_security_group.ec2
}

moved {
  from = aws_vpc_security_group_ingress_rule.api_http
  to   = module.security_group.aws_vpc_security_group_ingress_rule.ec2_api
}

moved {
  from = aws_vpc_security_group_ingress_rule.api_ssh
  to   = module.security_group.aws_vpc_security_group_ingress_rule.ec2_ssh
}

moved {
  from = aws_vpc_security_group_egress_rule.api_saida
  to   = module.security_group.aws_vpc_security_group_egress_rule.ec2_saida
}

moved {
  from = aws_security_group.db
  to   = module.security_group.aws_security_group.rds
}

moved {
  from = aws_vpc_security_group_ingress_rule.db_postgres
  to   = module.security_group.aws_vpc_security_group_ingress_rule.rds_postgres
}

# ----- rds -----
moved {
  from = random_password.db
  to   = module.rds.random_password.db
}

moved {
  from = aws_db_subnet_group.main
  to   = module.rds.aws_db_subnet_group.main
}

moved {
  from = aws_db_instance.postgres
  to   = module.rds.aws_db_instance.postgres
}

# ----- ec2 -----
moved {
  from = aws_instance.api
  to   = module.ec2.aws_instance.api
}
