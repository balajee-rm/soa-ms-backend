terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Security Group allowing required ports
resource "aws_security_group" "microservice_sg" {
  name        = "lab-microservice-sg"
  description = "Allow traffic for API Gateway, Eureka, and services"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "API Gateway"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Eureka Server"
    from_port   = 8761
    to_port     = 8761
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MS1"
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MS2.1"
    from_port   = 8002
    to_port     = 8002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MS2.2"
    from_port   = 8003
    to_port     = 8003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Latest Ubuntu 22.04 AMI Lookup
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

# 3. Create t3.small instance with corrected directory path
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = "vockey"
  vpc_security_group_ids = [aws_security_group.microservice_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io docker-compose-v2 git
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu

              # Clone repository
              git clone https://github.com/balajee-rm/soa-ms-backend.git /home/ubuntu/project
              
              # Navigate to project root where docker-compose.yml is located and launch stack
              cd /home/ubuntu/project
              docker compose up --build -d
              EOF

  tags = {
    Name = "Academy-Microservice-VM-T3"
  }
}

# 4. Outputs
output "ec2_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "Public IP of your AWS Academy instance"
}

output "api_gateway_cloud_url" {
  value       = "http://${aws_instance.app_server.public_ip}:8000"
  description = "Access URL for your API Gateway running in AWS Academy"
}