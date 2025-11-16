output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}

output "ec2_public_ips" {
  value = module.ec2.instance_public_ips
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}
