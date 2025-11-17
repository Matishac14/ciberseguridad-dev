variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "customer_gateway_ip" {
  description = "IP pública del customer gateway (pfSense)"
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
