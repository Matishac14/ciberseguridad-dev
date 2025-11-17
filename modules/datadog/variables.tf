variable "datadog_api_key" {
  description = "API Key de Datadog"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Application Key de Datadog"
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "Sitio de Datadog"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "monitor_alb" {
  description = "Crear monitores para ALB"
  type        = bool
  default     = true
}

variable "monitor_rds" {
  description = "Crear monitores para RDS"
  type        = bool
  default     = true
}

variable "monitor_ec2" {
  description = "Crear monitores para EC2"
  type        = bool
  default     = true
}

variable "monitor_wazuh" {
  description = "Crear monitores para Wazuh"
  type        = bool
  default     = true
}

variable "alb_arn" {
  description = "ARN del ALB"
  type        = string
}

variable "db_instance_id" {
  description = "ID de la instancia RDS"
  type        = string
}

variable "ec2_instance_ids" {
  description = "IDs de instancias EC2"
  type        = list(string)
}
