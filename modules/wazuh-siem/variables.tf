variable "instance_type" {
  description = "Tipo de instancia"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "key_name" {
  description = "Nombre de la llave SSH"
  type        = string
}

variable "siem_subnet" {
  description = "Subnet para SIEM"
  type        = string
}

variable "wazuh_sg_id" {
  description = "Security group ID"
  type        = string
}

variable "iam_role_name" {
  description = "Nombre del IAM role existente"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "wazuh_version" {
  description = "Versión de Wazuh"
  type        = string
}

variable "enable_public_access" {
  description = "Habilitar acceso público"
  type        = bool
}
