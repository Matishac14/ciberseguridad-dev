module "vpc" {
  source              = "./modules/vpc"
  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
}

module "security_group" {
  source       = "./modules/security_group"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  my_ip        = var.my_ip
}

module "ec2" {
  source        = "./modules/ec2"
  project_name  = var.project_name
  environment   = var.environment
  instance_type = var.instance_type
  docker_images = var.docker_images
  subnet_ids    = module.vpc.public_subnet_ids
  sg_id         = module.security_group.ec2_sg_id
}

module "alb" {
  source             = "./modules/alb"
  project_name       = var.project_name
  environment        = var.environment
  name               = "alb"
  vpc_id             = module.vpc.vpc_id
  security_group_id  = module.security_group.alb_sg_id
  subnet_ids         = module.vpc.public_subnet_ids
  target_group_name  = "${var.project_name}-${var.environment}-tg"
}

resource "aws_lb_target_group_attachment" "ec2" {
  count            = length(module.ec2.instance_ids)
  target_group_arn = module.alb.target_group_arn
  target_id        = element(module.ec2.instance_ids, count.index)
  port             = 80
}
