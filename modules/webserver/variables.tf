variable "instance_count" {
  description = "Número de instancias web"
  type        = number
}

variable "instance_type" {
  description = "Tipo de instancia"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Nombre de la llave SSH"
  type        = string
}

variable "private_subnets" {
  description = "Subnets privadas"
  type        = list(string)
}

variable "web_sg_id" {
  description = "Security group ID"
  type        = string
}

variable "target_group_arn" {
  description = "ARN del target group"
  type        = string
}

variable "iam_role_name" {
  description = "Nombre del IAM role"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "db_endpoint" {
  description = "Endpoint de la base de datos"
  type        = string
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

variable "wazuh_manager_ip" {
  description = "IP del Wazuh Manager"
  type        = string
}

variable "datadog_api_key" {
  description = "API Key de Datadog"
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "Sitio de Datadog"
  type        = string
}
