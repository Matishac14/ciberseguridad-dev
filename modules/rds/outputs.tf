output "db_instance_id" {
  description = "ID de la instancia RDS"
  value       = aws_db_instance.main.id
}

output "db_endpoint" {
  description = "Endpoint de la base de datos"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "db_address" {
  description = "Address de la base de datos"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "Puerto de la base de datos"
  value       = aws_db_instance.main.port
}

output "db_arn" {
  description = "ARN de la instancia RDS"
  value       = aws_db_instance.main.arn
}

output "db_name" {
  description = "Nombre de la base de datos"
  value       = aws_db_instance.main.db_name
}
