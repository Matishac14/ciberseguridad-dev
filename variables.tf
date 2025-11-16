variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "cheese-factory"
}

variable "environment" {
  description = "Entorno (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs de subredes públicas"
  type        = list(string)
  default     = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

variable "my_ip" {
  description = "IP para acceso SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "docker_images" {
  description = "Imágenes Docker a desplegar"
  type        = list(string)
  default     = ["errmcheesewensleydale","errmcheesecheddar","errmcheesestilton"]
}
