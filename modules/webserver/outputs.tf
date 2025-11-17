output "instance_ids" {
  description = "IDs de las instancias"
  value       = aws_instance.web[*].id
}

output "private_ips" {
  description = "IPs privadas de las instancias"
  value       = aws_instance.web[*].private_ip
}

output "instance_profile_arn" {
  description = "ARN del instance profile"
  value       = aws_iam_instance_profile.web_server.arn
}
