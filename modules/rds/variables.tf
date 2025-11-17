variable "identifier" {
  description = "Identificador de la instancia RDS"
  type        = string
}

variable "engine" {
  description = "Motor de base de datos"
  type        = string
}

variable "engine_version" {
  description = "Versión del motor"
  type        = string
}

variable "instance_class" {
  description = "Clase de instancia"
  type        = string
}

variable "allocated_storage" {
  description = "Almacenamiento en GB"
  type        = number
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "username" {
  description = "Usuario maestro"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Contraseña maestra"
  type        = string
  sensitive   = true
}

variable "db_subnet_group" {
  description = "Nombre del DB subnet group"
  type        = string
}

variable "db_sg_id" {
  description = "Security group ID"
  type        = string
}

variable "backup_retention" {
  description = "Días de retención de backups"
  type        = number
}

variable "multi_az" {
  description = "Habilitar Multi-AZ"
  type        = bool
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "monitoring_role_arn" {
  description = "ARN del rol para enhanced monitoring"
  type        = string
  default     = ""
}
