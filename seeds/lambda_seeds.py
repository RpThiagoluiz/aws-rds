import json
import os
import psycopg2
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def handler(event, context):
    """
    Lambda function para executar seeds no PostgreSQL RDS
    """
    
    try:
        # Variáveis de ambiente
        db_host = os.environ['DB_HOST']
        db_name = os.environ['DB_NAME']
        db_user = os.environ['DB_USER']
        db_password = os.environ['DB_PASSWORD']
        
        logger.info(f"Conectando ao banco: {db_host}")
        
        # Conectar ao PostgreSQL
        connection = psycopg2.connect(
            host=db_host,
            port=5432,
            database=db_name,
            user=db_user,
            password=db_password
        )
        
        cursor = connection.cursor()
        
        # Ler e executar o SQL de seeds
        with open('customers.sql', 'r') as sql_file:
            sql_commands = sql_file.read()
        
        logger.info("Executando seeds SQL...")
        
        # Executar comandos SQL
        cursor.execute(sql_commands)
        connection.commit()
        
        # Verificar dados inseridos
        cursor.execute("SELECT COUNT(*) FROM customers;")
        count = cursor.fetchone()[0]
        
        logger.info(f"Seeds executados com sucesso! Total de customers: {count}")
        
        # Fechar conexão
        cursor.close()
        connection.close()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Seeds executados com sucesso!',
                'customers_count': count
            })
        }
        
    except Exception as e:
        logger.error(f"Erro ao executar seeds: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'message': 'Erro ao executar seeds'
            })
        }
