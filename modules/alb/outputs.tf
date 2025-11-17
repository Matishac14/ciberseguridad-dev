output "alb_id" {
  description = "ID del ALB"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN del ALB"
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix del ALB"
  value       = aws_lb.main.arn_suffix
}

output "alb_name" {
  description = "Nombre del ALB"
  value       = aws_lb.main.name
}

output "alb_dns_name" {
  description = "DNS del ALB"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID del ALB"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN del target group"
  value       = aws_lb_target_group.main.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix del target group"
  value       = aws_lb_target_group.main.arn_suffix
}

output "target_group_name" {
  description = "Nombre del target group"
  value       = aws_lb_target_group.main.name
}

output "listener_http_arn" {
  description = "ARN del listener HTTP"
  value       = aws_lb_listener.http.arn
}

output "listener_https_arn" {
  description = "ARN del listener HTTPS"
  value       = var.enable_https ? aws_lb_listener.https[0].arn : null
}

output "alb_logs_bucket" {
  description = "Nombre del bucket de logs del ALB"
  value       = aws_s3_bucket.alb_logs.id
}

output "alb_url" {
  description = "URL del ALB"
  value       = var.enable_https ? "https://${aws_lb.main.dns_name}" : "http://${aws_lb.main.dns_name}"
}
