# Lambda function para executar seeds no RDS
resource "aws_lambda_function" "rds_seeds" {
  filename         = "seeds-lambda.zip"
  function_name    = "rds-seeds-function"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 300

  vpc_config {
    subnet_ids         = [aws_default_subnet.default_a.id, aws_default_subnet.default_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_HOST     = aws_db_instance.postgres.endpoint
      DB_NAME     = var.db_name
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
    }
  }

  depends_on = [aws_db_instance.postgres]

  tags = {
    Name        = "rds-seeds-function"
    Environment = var.environment
  }
}

# Security group para Lambda
resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda-seeds-sg-"
  vpc_id      = aws_default_vpc.default.id

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-seeds-sg"
  }
}

# IAM role para Lambda
resource "aws_iam_role" "lambda_role" {
  name_prefix = "lambda-seeds-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy para Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Data source para criar o ZIP da Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "seeds-lambda.zip"
  source {
    content  = file("${path.module}/../seeds/lambda_seeds.py")
    filename = "index.py"
  }
  source {
    content  = file("${path.module}/../seeds/customers.sql")
    filename = "customers.sql"
  }
}
