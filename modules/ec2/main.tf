data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  count                     = length(var.docker_images)
  ami                       = data.aws_ami.amazon_linux.id
  instance_type             = var.instance_type
  subnet_id                 = element(var.subnet_ids, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids    = [var.sg_id]

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    image = element(var.docker_images, count.index)
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-${count.index+1}"
  }
}
