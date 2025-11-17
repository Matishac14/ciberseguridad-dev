output "vpn_gateway_id" {
  description = "ID del VPN Gateway"
  value       = aws_vpn_gateway.main.id
}

output "vpn_connection_id" {
  description = "ID de la conexión VPN"
  value       = aws_vpn_connection.main.id
}

output "customer_gateway_configuration" {
  description = "Configuración del customer gateway"
  value       = aws_vpn_connection.main.customer_gateway_configuration
  sensitive   = true
}
