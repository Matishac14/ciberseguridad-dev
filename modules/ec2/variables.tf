variable "project_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "docker_images" {
  type = list(string)
}
variable "subnet_ids" {
  type = list(string)
}
variable "sg_id" {
  type = string
}
