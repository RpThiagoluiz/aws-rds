# Alternativa: Self-hosted runner (se quiser usar no futuro)

# EC2 para self-hosted runner
resource "aws_instance" "github_runner" {
  count           = 0  # Desabilitado por padrão
  ami             = "ami-0c02fb55956c7d316"  # Amazon Linux 2
  instance_type   = "t3.micro"
  subnet_id       = aws_default_subnet.default_a.id
  security_groups = [aws_security_group.runner_sg.id]
  
  user_data = <<-EOF
    #!/bin/bash
    # Script para configurar GitHub Actions runner
    # Adicionar aqui os comandos de setup do runner
  EOF

  tags = {
    Name = "github-actions-runner"
  }
}

resource "aws_security_group" "runner_sg" {
  count       = 0  # Desabilitado por padrão
  name_prefix = "github-runner-sg-"
  vpc_id      = aws_default_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
