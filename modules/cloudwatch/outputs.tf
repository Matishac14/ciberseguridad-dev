output "sns_topic_arn" {
  description = "ARN del SNS topic"
  value       = aws_sns_topic.alarms.arn
}

output "dashboard_url" {
  description = "URL del dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "dashboard_name" {
  description = "Nombre del dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "log_group_nginx_access" {
  description = "Nombre del log group de nginx access"
  value       = aws_cloudwatch_log_group.nginx_access.name
}

output "log_group_nginx_error" {
  description = "Nombre del log group de nginx error"
  value       = aws_cloudwatch_log_group.nginx_error.name
}
