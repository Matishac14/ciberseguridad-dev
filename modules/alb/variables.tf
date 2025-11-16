variable "project_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "name" {
  type = string
}
variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}
variable "security_group_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "target_group_name" {
  type = string
}
