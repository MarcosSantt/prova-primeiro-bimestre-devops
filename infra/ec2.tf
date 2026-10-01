# AMI mais recente do Amazon Linux 2023 (x86_64)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "api" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.publica[0].id
  vpc_security_group_ids = [aws_security_group.api.id]
  key_name               = var.key_name

  # Learner Lab não permite criar IAM roles: usa o perfil que já vem pronto
  iam_instance_profile = "LabInstanceProfile"

  # Instala Docker, clona o repo, builda a imagem e sobe a API apontando pro RDS
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    repo_url    = var.repo_url
    repo_branch = var.repo_branch
    db_host     = aws_db_instance.postgres.address
    db_port     = aws_db_instance.postgres.port
    db_name     = var.db_name
    db_user     = var.db_username
    db_password = random_password.db.result
  })
  # Mudou o script (ex.: nova senha ou novo endpoint)? Recria a instância
  user_data_replace_on_change = true

  # IMDSv2 obrigatório: protege as credenciais da instância contra SSRF
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${local.nome}-api"
  }
}
