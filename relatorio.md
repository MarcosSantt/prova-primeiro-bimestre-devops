# Relatório do Processo — Prova do Primeiro Bimestre (DevOps)

- **Aluno:** Marcos Eduardo Dos Santos Sousa
- **RA:** 6325127
- **Ferramenta de IA utilizada:** Claude (Anthropic), usado pelo chat e pelo Claude Code no terminal

---

## Questão 1 — A Jornada Completa (Aulas 01 a 07)

Segui a ordem sugerida no enunciado e na própria sequência das aulas: primeiro o código e o
versionamento, depois o container, depois o ambiente local e só no final a nuvem. Essa ordem faz
sentido porque cada etapa depende da anterior estar funcionando: não adianta provisionar uma EC2
para rodar uma imagem que ainda não builda, nem montar um RDS para uma API que ainda não grava
no banco. Assim, quando algo quebrava, eu sabia que o problema estava na camada nova.

Comecei pela **Aula 01 (Git)**: criei o repositório público, o `.gitignore` (node_modules, .env,
.terraform, *.tfstate, *.pem) e passei a trabalhar com Conventional Commits (`feat`, `chore`,
`docs`, `refactor`). Desenvolvi a API na branch `feature/api-reservas` e fiz o merge na `main`
quando ela e o ambiente Docker estavam prontos; a parte de nuvem foi feita na branch
`feature/terraform`. Ainda na **Aula 01 (Docker)**, criei a API Node.js/Express com o CRUD de
reservas gravando no PostgreSQL e escrevi um Dockerfile multi-stage (um estágio instala as
dependências com `npm ci --omit=dev` e o outro só copia o necessário), rodando com o usuário
não-root `node` e com `HEALTHCHECK`.

Na **Aula 02 (Docker Compose)** juntei a API e o PostgreSQL em um `docker-compose.yml` que sobe
tudo com um comando: volume nomeado para o banco não perder dados, rede bridge customizada,
healthcheck com `pg_isready` e `depends_on` com `condition: service_healthy`, para a API só
iniciar quando o banco estiver pronto. As senhas ficam no `.env` (ignorado pelo Git) e só o
`.env.example` é versionado.

Nas **Aulas 03 a 05 (Terraform, IAM, VPC, EC2 e RDS)** levei a mesma aplicação para a AWS: uma VPC
com subnets públicas e privadas em duas AZs, security groups com menor privilégio, uma EC2
t2.micro que clona o repositório, builda a imagem e roda o container, e um RDS PostgreSQL privado
e encriptado como banco da API. A parte de IAM apareceu justamente pela restrição do Learner Lab:
em vez de criar roles, usei o `LabInstanceProfile`. Na **Aula 06 (Remote State e Módulos)**, criei
antes o projeto `infra/backend` (bucket S3 versionado e encriptado + tabela DynamoDB para lock) e
depois configurei o `backend "s3"` no projeto principal. Em seguida modularizei a infraestrutura
em `vpc`, `security-group`, `ec2` e `rds`, compostos no `main.tf`: o `vpc_id` sai do módulo vpc e
entra no security-group, os IDs dos SGs e das subnets entram no rds e na ec2, e o endpoint e a
senha do RDS chegam ao `user_data` da EC2. Por fim, a **Aula 07 (IA como copiloto)** atravessou o
projeto inteiro, já que usei o Claude em todas as etapas, como descrevo na próxima questão.

---

## Questão 2 — O Processo com IA como Copiloto

Usei o **Claude** em todas as fases. Na API, no Dockerfile e no docker-compose usei o Claude pelo
chat: pedia cada parte separadamente (primeiro o servidor Express com a rota `/health`, depois o
CRUD com o driver `pg`, depois o Dockerfile multi-stage com usuário não-root e por último o Compose
com healthcheck e `depends_on`), lia o código gerado, rodava localmente e só então fazia o commit.
Nessa parte a IA gerou código que funcionou de primeira, sem erros relevantes; o que fiz foi conferir
se cada requisito do enunciado estava atendido (volume nomeado, rede customizada, `.env` fora do Git).

Na parte de Terraform usei o **Claude Code** no terminal, com acesso ao repositório. O prompt que
guiou o trabalho foi pedir para o Claude **ir me passando o passo a passo, se baseando nos TFs que
fizemos nas aulas**, para que a solução seguisse o que aprendi e eu executasse e entendesse cada
etapa. No meio do trabalho fechei a aba e **perdi o histórico da conversa**, por isso a sessão
seguinte começa com o prompt "onde paramos?": sem memória da conversa anterior, o Claude precisou
reconstruir o contexto lendo o repositório, os commits, os arquivos `.tf` e o state (foi assim que
descobriu que o primeiro `apply` do backend tinha ficado incompleto). Os outros prompts principais
foram pedir para finalizar o bootstrap do state remoto, escolher a arquitetura (EC2 + RDS) e,
depois, **colar o enunciado completo da prova** pedindo para comparar item por item com o que já
existia. Isso mostrou na prática que o Git também serve como "memória" do projeto quando o
contexto da IA se perde.
Não usei o Kiro Spec, mas acabei seguindo um fluxo parecido de requisitos → design → tarefas: o
enunciado funcionou como especificação, a IA montou uma tabela de lacunas e as tarefas foram
executadas e validadas uma a uma.

O que a IA fez bem: diagnosticou rápido a causa do primeiro `apply` do backend ter falhado (uma
política do Learner Lab nega `s3:GetBucketObjectLockConfiguration`, e o bucket ficou marcado como
*tainted*) e propôs a saída mais segura (`terraform untaint` + `apply -refresh=false`) em vez de
deixar o Terraform destruir e recriar o bucket. Também escreveu os módulos com boas práticas que eu
não tinha pedido explicitamente: IMDSv2 obrigatório, disco encriptado, senha do banco gerada com
`random_password` e marcada como sensível.

O que precisou ser corrigido: a **primeira versão da infra não era modularizada**, usava a porta 80
e uma instância t3.micro, porque eu ainda não tinha passado o enunciado para a IA e ela seguiu
padrões genéricos. Só percebi isso quando colei o enunciado. A correção foi refatorar para módulos
usando blocos `moved`, o que evitou recriar a VPC e o RDS: o plan mostrou só a EC2 sendo
substituída. Houve também um erro meu de uso: rodei `! cd infra/bootstrap && terraform apply` no
terminal normal, onde o `!` do bash inverte o resultado do `cd` e por isso o `apply` nunca rodou.
A IA identificou o motivo. Ela também cometeu um deslize ao remover do Git uma evidência que
valia manter e corrigiu antes do push.

Comparando com fazer manualmente, a IA economizou muito tempo no código repetitivo (variáveis,
outputs, regras de security group) e na investigação de erros da AWS, que eu levaria bem mais
tempo para entender. Atrapalhou quando trabalhou sem conhecer os requisitos: gerou uma solução
correta tecnicamente, mas diferente do pedido, e isso custou uma refatoração. A lição é que a IA
é tão boa quanto o contexto que recebe. O rascunho deste relatório também foi escrito com o
Claude, a partir do histórico real do projeto, e revisado e ajustado por mim.

---

## Questão 3 — Infraestrutura, Segurança e o Learner Lab

```
                         Internet
                            │
                     Internet Gateway
                            │
 ┌──────────────── VPC 10.0.0.0/16 (us-east-1) ─────────────────┐
 │  Subnets públicas (1a / 1b)                                  │
 │  ┌──────────────────────────────┐  SG ec2: 3000 (0.0.0.0/0)   │
 │  │ EC2 t2.micro + Docker (API)  │          22 (só o meu IP)   │
 │  │ LabInstanceProfile           │                            │
 │  └──────────────┬───────────────┘                            │
 │                 │ 5432 (SG rds aceita só o SG ec2)            │
 │  Subnets privadas (1a / 1b) — sem rota para a internet       │
 │  ┌──────────────▼───────────────┐                            │
 │  │ RDS PostgreSQL 16 db.t3.micro│  publicly_accessible=false  │
 │  │ storage_encrypted=true       │                            │
 │  └──────────────────────────────┘                            │
 └──────────────────────────────────────────────────────────────┘
 State remoto: S3 (versionado + AES256) + DynamoDB (lock)
```

A arquitetura tem uma VPC com quatro subnets em duas zonas de disponibilidade: duas públicas, com
rota para o Internet Gateway, e duas privadas, sem rota nenhuma para fora. A **EC2 fica na subnet
pública** porque precisa ser alcançada pelos clientes da API (porta 3000) e precisa sair para a
internet para instalar o Docker e clonar o repositório. O **RDS fica nas subnets privadas** porque
o banco não tem nenhum motivo para ser acessado de fora: só a API conversa com ele. Mesmo que
alguém descobrisse o endpoint, não existe rota da internet até ele, e testei isso: de fora da VPC
o endpoint nem resolve. O RDS exige um *DB subnet group* com subnets em pelo menos duas AZs, por
isso as privadas são duas.

A segurança foi feita em camadas. O security group do RDS libera a porta 5432 **apenas para o
security group da EC2** (referência de SG, não de IP), então só instâncias com aquele SG chegam ao
banco. O SG da EC2 libera a 3000 para todos e a 22 só para o meu IP (/32); coloquei uma validação
na variável para recusar `0.0.0.0/0` no SSH. O RDS tem `storage_encrypted = true` e
`publicly_accessible = false`, e a senha é gerada pelo Terraform e nunca aparece no código nem no
plan. O state fica no S3 com versionamento, encriptação e bloqueio de acesso público, porque ele
contém essa senha.

Como o Learner Lab **não permite criar IAM users, groups ou roles**, não criei nenhum recurso de
IAM: a EC2 usa o `iam_instance_profile = "LabInstanceProfile"`, que já existe na conta e carrega a
`LabRole`. Para mim isso simplificou o código, mas também mostrou o lado ruim: não tenho controle
sobre as permissões dessa role, então não dá para aplicar menor privilégio no IAM como seria numa
conta real. O acesso SSH usa a key pair `vockey`, que o Lab também já fornece.

O Lab exigiu outros ajustes. As **credenciais são temporárias** (com `aws_session_token`) e
expiraram durante o trabalho: o Terraform passou a dar `ExpiredToken` e precisei reiniciar o Lab
e atualizar o `~/.aws/credentials` em AWS Details → AWS CLI. A **região é sempre us-east-1**. A
restrição mais inesperada foi uma *Service Control Policy* que nega
`s3:GetBucketObjectLockConfiguration`: o provider AWS lê essa configuração a cada refresh do bucket,
então o projeto `infra/backend` precisa ser aplicado com `-refresh=false`. Além disso, quando a
sessão do Lab termina a EC2 é desligada e volta com outro IP público, e o RDS continua consumindo
créditos, por isso o `terraform destroy` no final é obrigatório.

---

## Questão 4 — Validação e Responsabilidade

Antes de cada `terraform apply` em código gerado pela IA, apliquei este checklist:

1. `terraform fmt` e `terraform validate` sem erros.
2. Ler o `terraform plan` inteiro e conferir a linha `Plan: X to add, Y to change, Z to destroy`.
   Na modularização, conferi que o resultado era `1 to add, 1 to change, 1 to destroy` e que o
   único recurso destruído era a EC2, nunca o RDS ou a VPC.
3. Conferir que nenhum segredo aparece no plan (a senha e o `user_data` aparecem como
   `(sensitive value)`) e que `terraform.tfvars`, `*.tfstate` e `tfplan` não entram no Git.
4. Revisar as regras de segurança: 5432 só a partir do SG da EC2, SSH só do meu IP,
   `publicly_accessible = false` e `storage_encrypted = true`.
5. Conferir que nenhum recurso de IAM é criado, só o `LabInstanceProfile` é referenciado.
6. Salvar o plan em arquivo (`-out=tfplan`) e aplicar exatamente esse plan revisado.

Para validar depois do apply, testei a API na nuvem com `curl`: `/health` respondendo
`banco: conectado` (o que prova a conexão EC2 → RDS) e o CRUD completo, incluindo a validação de
campos (400) e a busca de um id apagado (404). Verifiquei com o AWS CLI que o RDS estava com
`PubliclyAccessible: False` e `Encrypted: True` e tentei conectar no endpoint de fora da VPC, sem
sucesso, como esperado. Depois da recriação da EC2, a nova reserva recebeu o id 2, prova de que
os dados do RDS sobreviveram. As saídas estão na pasta `evidencias/`.

Também mantive a responsabilidade de executar as ações que mudam a infraestrutura. O Claude Code
rodava `plan`, testes e comandos de leitura, mas o `terraform apply` com `-auto-approve` foi
bloqueado pelo controle de permissões da ferramenta, então os applies foram executados por mim, no
meu terminal, depois de revisar o plan. Achei isso correto: quem responde pela infraestrutura e
pelos créditos gastos sou eu, não a IA.

Se eu aceitasse o código sem revisar, teria entregue uma infraestrutura sem módulos, na porta
errada e com o tipo de instância errado, perdendo nota na parte de maior peso. No backend, se
tivesse simplesmente rodado `apply` de novo com o bucket *tainted*, o Terraform tentaria destruir e
recriar o bucket do state e falharia do mesmo jeito. Em um caso pior, um plan não lido poderia
destruir o RDS com os dados, abrir o banco para a internet ou commitar o state com a senha.

A evolução Git → Docker → Terraform → Módulos me preparou para isso porque cada etapa me deu uma
forma de verificar a anterior. O Git me deixa revisar cada mudança da IA em commits pequenos e
voltar atrás. O Docker garante que o que testei localmente é o mesmo que roda na EC2. O Terraform
mostra no plan o que vai acontecer antes de acontecer. Os módulos dividem a infraestrutura em
partes pequenas que consigo ler e entender uma por vez. Com essas ferramentas, consigo usar a IA
para acelerar sem abrir mão de entender e validar cada decisão.
