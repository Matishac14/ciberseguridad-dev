data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.environment}-bastion-profile"
  role = var.iam_role_name

  tags = {
    Name        = "${var.environment}-bastion-profile"
    Environment = var.environment
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Actualizar sistema
              yum update -y

              # Instalar herramientas útiles
              yum install -y mysql telnet nc wget curl htop

              # Instalar Session Manager plugin
              yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

              # Configurar banner SSH
              cat > /etc/ssh/banner <<BANNER
              ╔═══════════════════════════════════════════════╗
              ║     BASTION HOST - Evaluación Parcial 3       ║
              ║                                               ║
              ║  Acceso autorizado únicamente                 ║
              ║  Todas las actividades son monitoreadas      ║
              ╚═══════════════════════════════════════════════╝
              BANNER

              echo "Banner /etc/ssh/banner" >> /etc/ssh/sshd_config
              systemctl restart sshd

              # Crear script de conexión rápida
              cat > /home/ec2-user/connect-to-web.sh <<'SCRIPT'
              #!/bin/bash
              echo "Servidores Web disponibles:"
              echo "1) Web Server 1"
              echo "2) Web Server 2"
              echo "3) Web Server 3"
              read -p "Seleccione servidor (1-3): " choice

              case $choice in
                1) ssh ec2-user@10.0.10.X ;;
                2) ssh ec2-user@10.0.20.X ;;
                3) ssh ec2-user@10.0.30.X ;;
                *) echo "Opción inválida" ;;
              esac
              SCRIPT

              chmod +x /home/ec2-user/connect-to-web.sh
              chown ec2-user:ec2-user /home/ec2-user/connect-to-web.sh

              echo "Bastion host configurado correctamente"
              EOF

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.environment}-bastion"
    Environment = var.environment
    Role        = "bastion"
    Purpose     = "ssh-gateway"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name        = "${var.environment}-bastion-eip"
    Environment = var.environment
  }
}
