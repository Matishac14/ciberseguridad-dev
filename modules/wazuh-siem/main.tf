data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Instance Profile usando LabRole existente
resource "aws_iam_instance_profile" "wazuh" {
  name = "${var.environment}-wazuh-profile"
  role = var.iam_role_name
}

resource "aws_instance" "wazuh_manager" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.siem_subnet
  vpc_security_group_ids = [var.wazuh_sg_id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.wazuh.name

  associate_public_ip_address = var.enable_public_access

  user_data = templatefile("${path.module}/scripts/wazuh-manager-setup.sh", {
    wazuh_version = var.wazuh_version
  })

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 50
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.environment}-wazuh-manager"
    Environment = var.environment
    Purpose     = "SIEM"
    Tool        = "Wazuh"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP para acceso estable
resource "aws_eip" "wazuh" {
  count    = var.enable_public_access ? 1 : 0
  instance = aws_instance.wazuh_manager.id
  domain   = "vpc"

  tags = {
    Name        = "${var.environment}-wazuh-eip"
    Environment = var.environment
  }
}
