variable "alb_arn" {
  description = "ARN del ALB"
  type        = string
}

variable "alb_name" {
  description = "Nombre del ALB"
  type        = string
}

variable "target_group_arn" {
  description = "ARN del target group"
  type        = string
}

variable "instance_ids" {
  description = "IDs de las instancias EC2"
  type        = list(string)
}

variable "db_instance_id" {
  description = "ID de la instancia RDS"
  type        = string
}

variable "wazuh_instance_id" {
  description = "ID de la instancia Wazuh"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "alarm_email" {
  description = "Email para alarmas"
  type        = string
}
