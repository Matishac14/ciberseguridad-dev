output "wazuh_instance_id" {
  description = "ID de la instancia Wazuh"
  value       = aws_instance.wazuh_manager.id
}

output "wazuh_manager_private_ip" {
  description = "IP privada del Wazuh Manager"
  value       = aws_instance.wazuh_manager.private_ip
}

output "wazuh_manager_public_ip" {
  description = "IP pública del Wazuh Manager"
  value       = var.enable_public_access ? aws_eip.wazuh[0].public_ip : null
}

output "wazuh_dashboard_url" {
  description = "URL del dashboard de Wazuh"
  value       = var.enable_public_access ? "<https://${aws_eip.wazuh>[0].public_ip}" : null
}
