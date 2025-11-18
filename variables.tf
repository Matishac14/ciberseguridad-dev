variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

# VPC Variables
variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
}

variable "vpc_public_subnets" {
  description = "Subnets públicas"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "Subnets privadas"
  type        = list(string)
}

variable "vpc_database_subnets" {
  description = "Subnets para base de datos"
  type        = list(string)
}

variable "vpc_siem_subnet" {
  description = "Subnet para SIEM (pública o privada según necesidad)"
  type        = string
}

# Network Variables
variable "my_public_ip" {
  description = "Tu IP pública en notación CIDR"
  type        = string
}

variable "onpremise_cidr" {
  description = "CIDR de la red on-premise (pfSense)"
  type        = string
}

variable "pfsense_public_ip" {
  description = "IP pública de pfSense para VPN"
  type        = string
  default     = ""
}

variable "enable_vpn" {
  description = "Habilitar VPN Site-to-Site con on-premise"
  type        = bool
  default     = false
}

# Web Server Variables
variable "webserver_count" {
  description = "Número de servidores web"
  type        = number
  default     = 3
}

variable "webserver_instance_type" {
  description = "Tipo de instancia para web servers"
  type        = string
  default     = "t3.micro"
}

variable "webserver_ami_id" {
  description = "AMI ID para servidores web"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Nombre de la llave SSH"
  type        = string
}

variable "health_check_path" {
  description = "Path para health check del ALB"
  type        = string
  default     = "/health"
}

# RDS Variables
variable "db_engine" {
  description = "Motor de base de datos"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Versión del motor"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "Clase de instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Almacenamiento asignado en GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}

variable "db_backup_retention" {
  description = "Días de retención de backups"
  type        = number
  default     = 7
}

variable "db_multi_az" {
  description = "Habilitar Multi-AZ"
  type        = bool
  default     = false
}

# Wazuh SIEM Variables
variable "wazuh_instance_type" {
  description = "Tipo de instancia para Wazuh Manager"
  type        = string
  default     = "t3.medium"
}

variable "wazuh_ami_id" {
  description = "AMI ID para Wazuh (Ubuntu 22.04 recomendado)"
  type        = string
  default     = ""
}

variable "wazuh_version" {
  description = "Versión de Wazuh a instalar"
  type        = string
  default     = "4.7"
}

variable "wazuh_enable_public_access" {
  description = "Habilitar acceso público al dashboard de Wazuh"
  type        = bool
  default     = true
}

# Datadog Variables
variable "datadog_api_key" {
  description = "API Key de Datadog"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Application Key de Datadog"
  type        = string
  sensitive   = true
  default     = ""
}

variable "datadog_site" {
  description = "Sitio de Datadog (datadoghq.com, datadoghq.eu, etc.)"
  type        = string
  default     = "datadoghq.com"
}

# CloudWatch Variables
variable "alarm_email" {
  description = "Email para alarmas de CloudWatch"
  type        = string
}

# Bastion Variables
variable "enable_bastion" {
  description = "Crear bastion host"
  type        = bool
  default     = true
}
variable "certificate_arn" {
  description = "ARN del certificado SSL para HTTPS en ALB"
  type        = string
  default     = ""
}

variable "enable_alb_https" {
  description = "Habilitar HTTPS en el ALB"
  type        = bool
  default     = false
}
