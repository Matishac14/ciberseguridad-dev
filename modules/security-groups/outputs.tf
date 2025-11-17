output "alb_sg_id" {
  description = "ID del security group del ALB"
  value       = aws_security_group.alb.id
}

output "web_sg_id" {
  description = "ID del security group de web servers"
  value       = aws_security_group.web.id
}

output "db_sg_id" {
  description = "ID del security group de RDS"
  value       = aws_security_group.db.id
}

output "wazuh_sg_id" {
  description = "ID del security group de Wazuh"
  value       = aws_security_group.wazuh.id
}

output "bastion_sg_id" {
  description = "ID del security group del bastion"
  value       = aws_security_group.bastion.id
}
