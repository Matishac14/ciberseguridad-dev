variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "my_public_ip" {
  description = "IP pública en notación CIDR"
  type        = string
}

variable "onpremise_cidr" {
  description = "CIDR de la red on-premise"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}
