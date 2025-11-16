output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN del target group del ALB"
  value       = aws_lb_target_group.this.arn
}
