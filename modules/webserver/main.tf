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

resource "aws_iam_instance_profile" "web_server" {
  name = "${var.environment}-web-server-profile"
  role = var.iam_role_name

  tags = {
    Name        = "${var.environment}-web-server-profile"
    Environment = var.environment
  }
}

resource "aws_instance" "web" {
  count                  = var.instance_count
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnets[count.index % length(var.private_subnets)]
  vpc_security_group_ids = [var.web_sg_id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.web_server.name

  user_data = templatefile("${path.module}/scripts/web-server-setup.sh", {
    db_endpoint      = var.db_endpoint
    db_name          = var.db_name
    db_username      = var.db_username
    db_password      = var.db_password
    wazuh_manager_ip = var.wazuh_manager_ip
    datadog_api_key  = var.datadog_api_key
    datadog_site     = var.datadog_site
    environment      = var.environment
    server_index     = count.index + 1
  })

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.environment}-web-${count.index + 1}"
    Environment = var.environment
    Role        = "webserver"
    Monitoring  = "datadog,cloudwatch,wazuh"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "web" {
  count            = var.instance_count
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}
