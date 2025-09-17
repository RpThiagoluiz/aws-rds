# rds-postgrels

Infraestrutura e automação para Amazon RDS (PostgreSQL)

## Objetivo

- Provisionar banco PostgreSQL (RDS) para uso com Lambda/API
- Scripts de seed e migração
- Pipeline CI/CD para automação

## Estrutura sugerida

- `infra/` — IaC (ex: Terraform, CloudFormation)
- `seeds/` — Scripts de seed SQL
- `.github/workflows/` — CI/CD

## Como usar

1. Configure variáveis de ambiente (exemplo: conexão RDS)
2. Execute scripts de seed/migração conforme instruções
3. Use a pipeline para automação

---

> Estrutura inicial criada automaticamente. Complete conforme necessidade do projeto.
