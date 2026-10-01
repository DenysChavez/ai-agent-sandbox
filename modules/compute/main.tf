# Trae automaticamente el ID mas reciente de Amazon Linux 2023, sin hardcodear un AMI ID que caduca
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-20*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ec2_agent_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group para la EC2 del agente - sin inbound, solo SSM"
  vpc_id      = var.vpc_id

  # Sin bloques 'ingress' - cero puertos abiertos hacia adentro

  egress {
    description = "Salida completa (necesaria para SSM, descargar modelos, apt/dnf)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

resource "aws_instance" "agent" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_agent_sg.id]
  iam_instance_profile   = var.instance_profile_name

  user_data = <<-EOF
    #!/bin/bash
    echo "=== SSM AGENT STATUS ==="
    systemctl status amazon-ssm-agent
    echo "=== SSM AGENT VERSION ==="
    /usr/bin/amazon-ssm-agent --version
    echo "=== DNS TEST ==="
    nslookup ssm.us-east-1.amazonaws.com
    echo "=== CONNECTIVITY TEST ==="
    curl -v --max-time 10 https://ssm.us-east-1.amazonaws.com 2>&1
    echo "=== SSM AGENT LOGS (last 50 lines) ==="
    tail -n 50 /var/log/amazon/ssm/amazon-ssm-agent.log
  EOF

  user_data_replace_on_change = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type            = "gp3"
    encrypted              = true
  }

  metadata_options {
    http_tokens = "required"  # Fuerza IMDSv2, mas seguro que IMDSv1
  }

  tags = {
    Name = "${var.project_name}-agent"
  }
}
