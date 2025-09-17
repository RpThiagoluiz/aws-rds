#!/bin/bash

# Script para executar seeds no PostgreSQL RDS
# Uso: ./run-seeds.sh

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🌱 Executando seeds no PostgreSQL RDS${NC}"

# Verificar se as variáveis de ambiente estão definidas
if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
    echo -e "${RED}❌ Variáveis de ambiente necessárias não definidas:${NC}"
    echo "  - DB_HOST"
    echo "  - DB_USER" 
    echo "  - DB_PASSWORD"
    echo "  - DB_NAME"
    exit 1
fi

# Instalar psql se necessário (para GitHub Actions)
if ! command -v psql &> /dev/null; then
    echo -e "${YELLOW}📦 Instalando PostgreSQL client...${NC}"
    apt-get update && apt-get install -y postgresql-client
fi

# Executar seed de customers
echo -e "${YELLOW}🏃 Executando seed customers.sql...${NC}"

# Remover porta do host se estiver presente (ex: host:5432 -> host)
DB_HOST_CLEAN=$(echo $DB_HOST | cut -d':' -f1)

PGPASSWORD=$DB_PASSWORD psql \
    -h $DB_HOST_CLEAN \
    -p 5432 \
    -U $DB_USER \
    -d $DB_NAME \
    -f customers.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Seeds executados com sucesso!${NC}"
else
    echo -e "${RED}❌ Erro ao executar seeds${NC}"
    exit 1
fi

# Verificar dados inseridos
echo -e "${YELLOW}🔍 Verificando dados inseridos...${NC}"

PGPASSWORD=$DB_PASSWORD psql \
    -h $DB_HOST_CLEAN \
    -p 5432 \
    -U $DB_USER \
    -d $DB_NAME \
    -c "SELECT COUNT(*) as total_customers FROM customers;"

echo -e "${GREEN}🎉 Processo de seed finalizado!${NC}"
