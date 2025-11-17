variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
}

variable "availability_zones" {
  description = "Lista de zonas de disponibilidad"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDRs de subnets públicas"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDRs de subnets privadas"
  type        = list(string)
}

variable "database_subnets" {
  description = "CIDRs de subnets para base de datos"
  type        = list(string)
}

variable "siem_subnet" {
  description = "CIDR de subnet para SIEM"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}
