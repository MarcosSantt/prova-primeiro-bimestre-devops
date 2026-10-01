# TechNova — API de Reservas

Projeto da Prova do Primeiro Bimestre de DevOps (Análise e Desenvolvimento de Sistemas — 2026.2).

- **Aluno:** Marcos Eduardo Dos Santos Sousa
- **RA:** 6325127
- **Ferramenta de IA utilizada:** Claude (Claude Code) — ver [relatorio.md](relatorio.md)

API REST de reservas em **Node.js + Express + PostgreSQL**, containerizada com **Docker**,
com ambiente local via **Docker Compose** e infraestrutura na **AWS** (AWS Academy Learner Lab)
provisionada com **Terraform modularizado** e **state remoto** (S3 + DynamoDB).

## Rotas da API

| Método   | Rota            | Descrição                                        |
|----------|-----------------|--------------------------------------------------|
| `POST`   | `/reservas`     | Cria uma reserva (`cliente` e `data` obrigatórios) |
| `GET`    | `/reservas`     | Lista todas as reservas                          |
| `GET`    | `/reservas/:id` | Busca uma reserva (404 se não existir)           |
| `PUT`    | `/reservas/:id` | Atualiza uma reserva                             |
| `DELETE` | `/reservas/:id` | Remove uma reserva                               |
| `GET`    | `/health`       | Health check (testa também a conexão com o banco) |

Campos de uma reserva: `id`, `cliente`, `data` (`YYYY-MM-DD`) e `status`
(`pendente`, `confirmada` ou `cancelada`). Os dados ficam no PostgreSQL — no container
`db` localmente e no RDS na nuvem.

## Estrutura do repositório

```
├── app/                    # API de Reservas (Dockerfile multi-stage, usuário não-root)
├── docker-compose.yml      # API + PostgreSQL (ambiente local)
├── .env.example            # modelo de variáveis (o .env real não vai para o Git)
├── infra/
│   ├── backend/            # S3 + DynamoDB do remote state (state local, roda 1 vez)
│   ├── modules/
│   │   ├── vpc/            # VPC, subnets públicas/privadas em 2 AZs, IGW, rotas
│   │   ├── security-group/ # SG da EC2 (22, 3000) e do RDS (5432 só do SG da EC2)
│   │   ├── ec2/            # EC2 t2.micro que builda e roda a API via user_data
│   │   └── rds/            # RDS PostgreSQL db.t3.micro privado e encriptado
│   ├── main.tf             # composição dos módulos
│   ├── moved.tf            # migração do state para os módulos sem recriar recursos
│   ├── providers.tf        # provider AWS + backend "s3"
│   ├── variables.tf
│   └── outputs.tf
├── evidencias/             # saídas de comandos e screenshots
└── relatorio.md            # relatório do processo com IA
```

## Arquitetura na AWS

```
                         Internet
                            │
                     Internet Gateway
                            │
 ┌──────────────── VPC 10.0.0.0/16 (us-east-1) ─────────────────┐
 │                                                              │
 │  Subnets públicas (us-east-1a / 1b)                          │
 │  ┌──────────────────────────────┐                            │
 │  │ EC2 t2.micro (AL2023)        │  SG ec2: 3000 (0.0.0.0/0)   │
 │  │ Docker: technova-api :3000   │          22 (só IP admin)   │
 │  │ LabInstanceProfile           │                            │
 │  └──────────────┬───────────────┘                            │
 │                 │ 5432 (SG rds aceita só o SG ec2)            │
 │  Subnets privadas (us-east-1a / 1b) — sem rota p/ internet   │
 │  ┌──────────────▼───────────────┐                            │
 │  │ RDS PostgreSQL 16            │  publicly_accessible=false  │
 │  │ db.t3.micro, encriptado      │  storage_encrypted=true     │
 │  └──────────────────────────────┘                            │
 └──────────────────────────────────────────────────────────────┘

 State remoto: S3 technova-tfstate-6325127 (versionado + AES256)
               DynamoDB technova-terraform-locks (lock)
```

## Ambiente local (Docker Compose)

```bash
cp .env.example .env        # troque a senha no .env
docker compose up -d --build
docker compose ps           # api e db devem estar "healthy"
curl http://localhost:3000/health
```

## Deploy na AWS (Learner Lab)

Pré-requisitos: Terraform >= 1.5, AWS CLI e as credenciais do Lab
(**AWS Details → AWS CLI**) em `~/.aws/credentials`. Região sempre `us-east-1`.

```bash
# 1. Backend do state remoto (apenas uma vez)
cd infra/backend
terraform init
terraform apply -refresh=false   # ver observação abaixo

# 2. Infraestrutura principal
cd ..
cp terraform.tfvars.example terraform.tfvars   # informe seu IP em ssh_allowed_cidr
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

# 3. Testar (a EC2 leva ~3 min após o apply para buildar a imagem)
curl "$(terraform output -raw api_health_url)"

# 4. Ao terminar, SEMPRE destruir para não gastar créditos
terraform destroy
cd backend && terraform destroy
```

> **Observação (Learner Lab):** a política da conta nega `s3:GetBucketObjectLockConfiguration`,
> que o provider AWS consulta ao ler um `aws_s3_bucket`. Por isso o projeto `infra/backend`
> é aplicado com `-refresh=false`. O projeto principal não é afetado, pois só usa o bucket
> como backend.

## Evidências

Ver a pasta [`evidencias/`](evidencias/): build da imagem, `docker compose ps`, testes da API
local e na AWS, `terraform plan`/`apply` e screenshots do console.
