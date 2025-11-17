output "dashboard_url" {
  description = "URL del dashboard de Datadog"
  value       = "https://app.${var.datadog_site}/dashboard/${datadog_dashboard.main.id}"
}

output "dashboard_id" {
  description = "ID del dashboard"
  value       = datadog_dashboard.main.id
}
