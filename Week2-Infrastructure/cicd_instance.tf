#############################################
# Week 3: Dedicated EC2 instance for CI/CD deployment demo
#
# This is separate from the Auto Scaling Group in compute.tf.
# ASG instances change IP addresses as they scale, which makes
# them unreliable SSH targets for a CI/CD pipeline. This single
# instance has a fixed public IP and SSH access instead.
#############################################

# Generates a fresh SSH key pair - the private key is used by
# GitHub Actions to connect, the public key is installed on the instance.
resource "tls_private_key" "cicd" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cicd" {
  key_name   = "${var.project_name}-cicd-key"
  public_key = tls_private_key.cicd.public_key_openssh
}

# Security group: allows SSH (for GitHub Actions to deploy) and the
# app port (so you can view the deployed app directly in a browser).
# NOTE: SSH is open to the internet (0.0.0.0/0) here for simplicity,
# since GitHub-hosted runners don't have fixed IP addresses. In a
# real production setup, you'd restrict this further (e.g. a
# self-hosted runner, VPN, or IP allowlist).
resource "aws_security_group" "cicd_instance" {
  name        = "${var.project_name}-cicd-sg"
  description = "Allow SSH for CI/CD deploys and direct app access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere (CI/CD pipeline)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port, for direct browser access"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-cicd-sg"
  }
}

resource "aws_instance" "cicd" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.cicd_instance.id]
  key_name                    = aws_key_pair.cicd.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.app_instance.name

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    docker_image = var.docker_image
    app_port     = var.app_port
    db_host      = aws_db_instance.main.address
    db_username  = var.db_username
    db_password  = var.db_password
    db_name      = var.db_name
  })

  tags = {
    Name = "${var.project_name}-cicd-instance"
  }
}
