# rds-postgrels

Infraestrutura e automação para Amazon RDS (PostgreSQL) compatível com AWS Academy

## 🎯 Objetivo

Provisionar e configurar um banco PostgreSQL (RDS) na AWS com seeds de dados automatizados via GitHub Actions.

## 🏗️ Arquitetura

### Componentes principais:

- **RDS PostgreSQL**: Banco gerenciado na AWS (t3.micro, 20GB)
- **GitHub Actions**: CI/CD para deploy automático
- **Terraform**: Infraestrutura como código (IaC)
- **Seeds SQL**: População inicial de dados

### Configuração para AWS Academy:

- ✅ RDS público (`publicly_accessible = true`)
- ✅ Security Group aberto (porta 5432)
- ✅ Seeds via psql direto (sem Lambda/IAM complexo)

## 📁 Estrutura do Projeto

```
rds-postgrels/
├── .github/workflows/
│   └── deploy.yml              # Workflow principal de deploy
├── infra/
│   └── main.tf                 # Infraestrutura Terraform (RDS + SG)
├── seeds/
│   ├── customers.sql           # Script SQL com dados de teste
│   └── run-seeds.sh           # Executor de seeds (psql)
└── README.md                  # Este arquivo
```

## 🔧 Como cada arquivo funciona

### `.github/workflows/deploy.yml`

**Função**: Orquestra todo o processo de deploy
**Etapas**:

1. **Setup**: Instala Terraform, AWS CLI, PostgreSQL client
2. **Credenciais**: Configura acesso AWS (Academy)
3. **Terraform Init**: Inicializa estado do Terraform
4. **Import**: Tenta importar recursos existentes (evita conflitos)
5. **Plan/Apply**: Planeja e executa mudanças na infraestrutura
6. **Seeds**: Executa scripts SQL para popular dados

### `infra/main.tf`

**Função**: Define toda a infraestrutura AWS como código
**Recursos criados**:

- `aws_default_vpc`: Usa VPC padrão
- `aws_default_subnet`: Subnets nas AZs a/b
- `aws_security_group`: Firewall (porta 5432 aberta)
- `aws_db_subnet_group`: Grupo de subnets para RDS
- `aws_db_instance`: Instância PostgreSQL principal

**Variáveis importantes**:

- `db_password`: Senha do banco (via secret)
- `db_username`: Usuário master (`postgres`)
- `db_name`: Nome do banco (`customer_db`)

### `seeds/customers.sql`

**Função**: Script SQL para criar estrutura e dados iniciais
**O que faz**:

- Cria tabela `customers` com campos: id, cpf, name, email, timestamps
- Adiciona índices para performance
- Insere 5 clientes de exemplo
- Configura triggers para `updated_at` automático

### `seeds/run-seeds.sh`

**Função**: Script bash que executa os seeds SQL
**Processo**:

1. Valida variáveis de ambiente (DB_HOST, DB_USER, etc.)
2. Instala `psql` se necessário
3. Limpa endpoint (remove `:5432` se presente)
4. Executa `customers.sql` via `psql`
5. Verifica se dados foram inseridos

## 🚀 Como usar

### 1. Configurar Secrets no GitHub

Adicione em `Settings > Secrets and variables > Actions`:

```
FIAP_POS_AWS_ACCESS_KEY_ID      # AWS Access Key
FIAP_POS_AWS_SECRET_ACCESS_KEY  # AWS Secret Key
FIAP_POS_AWS_SESSION_TOKEN      # AWS Session Token
FIAP_POS_AWS_REGION             # Região (ex: us-east-1)
FIAP_POS_AWS_ROLE_ARN          # ARN do Role (se necessário)
DB_PASSWORD                     # Senha do PostgreSQL
DB_USER                         # Usuário (ex: postgres)
```

### 2. Executar Deploy

- **Push para main**: Deploy automático
- **Manual**: Actions > Run workflow

### 3. Acessar o banco

Após o deploy, use as informações do output:

```bash
# Endpoint será algo como:
# fiap-customer-db.abc123.us-east-1.rds.amazonaws.com

psql -h <endpoint> -U postgres -d customer_db
```

## 📊 Dados de Teste

O banco vem com 5 clientes pré-cadastrados:

| CPF         | Nome            | Email                     |
| ----------- | --------------- | ------------------------- |
| 69281929090 | João Silva      | joao.silva@email.com      |
| 52400561028 | Maria Santos    | maria.santos@email.com    |
| 12067454013 | Pedro Oliveira  | pedro.oliveira@email.com  |
| 50642613060 | Ana Costa       | ana.costa@email.com       |
| 98765432100 | Carlos Ferreira | carlos.ferreira@email.com |

## 🔄 Workflow Detalhado

### Tempo estimado: ~8-12 minutos

1. **Setup (2min)**: Instalar ferramentas
2. **Import (2-4min)**: Verificar recursos existentes
3. **Apply (3-5min)**: Criar/modificar RDS
4. **Seeds (1-2min)**: Popular dados

### Estados possíveis:

- **Primeira execução**: Cria tudo do zero
- **Execuções seguintes**: Detecta mudanças e aplica apenas o necessário
- **Rollback**: Use `terraform destroy` manual se necessário

## 🎓 Compatibilidade AWS Academy

Este projeto foi otimizado para **AWS Academy Learner Lab**:

- ❌ **Sem Lambda**: Evita problemas de IAM
- ❌ **Sem VPC customizada**: Usa VPC padrão
- ✅ **RDS público**: Acessível de fora da AWS
- ✅ **Permissões básicas**: Só precisa de RDS + EC2

## 🔧 Troubleshooting

### RDS não conecta:

- Verificar security group (porta 5432)
- Confirmar que `publicly_accessible = true`
- Testar com `telnet <endpoint> 5432`

### Seeds falham:

- Verificar credenciais (DB_PASSWORD)
- RDS pode estar em "modifying" (aguardar)
- Logs completos em Actions

### Terraform trava:

- Importar recursos: `terraform import aws_db_instance.postgres <id>`
- Reset state: `terraform refresh`

---

## 📚 Conceitos Estudados

- **IaC (Infrastructure as Code)**: Terraform
- **CI/CD**: GitHub Actions
- **RDS**: Banco gerenciado AWS
- **Security Groups**: Firewall AWS
- **Secrets Management**: GitHub Secrets
- **SQL Seeds**: População inicial de dados

**Próximos passos**: Integrar este RDS com aplicações Lambda ou API Gateway! 🚀
