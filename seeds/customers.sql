-- Seed data for customer database
-- Execute este script após a criação do RDS PostgreSQL

-- Criação da tabela customers
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cpf VARCHAR(11) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índice para busca por CPF
CREATE INDEX IF NOT EXISTS idx_customers_cpf ON customers(cpf);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para atualizar updated_at
DROP TRIGGER IF EXISTS update_customers_updated_at ON customers;
CREATE TRIGGER update_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Inserção de dados de exemplo
INSERT INTO customers (cpf, name, email) VALUES
    ('69281929090', 'João Silva', 'joao.silva@email.com'),
    ('52400561028', 'Maria Santos', 'maria.santos@email.com'),
    ('12067454013', 'Pedro Oliveira', 'pedro.oliveira@email.com'),
    ('50642613060', 'Ana Costa', 'ana.costa@email.com'),
    ('98765432100', 'Carlos Ferreira', 'carlos.ferreira@email.com')
ON CONFLICT (cpf) DO NOTHING;

-- Verificação dos dados inseridos
SELECT 
    id,
    cpf,
    name,
    email,
    created_at
FROM customers 
ORDER BY created_at;
