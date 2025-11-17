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

variable "public_subnet" {
  description = "Subnet pública"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security group ID"
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
