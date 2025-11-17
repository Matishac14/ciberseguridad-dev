output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "IDs de subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "IDs de subnets privadas"
  value       = aws_subnet.private[*].id
}

output "database_subnets" {
  description = "IDs de subnets de base de datos"
  value       = aws_subnet.database[*].id
}

output "siem_subnet" {
  description = "ID de subnet SIEM"
  value       = aws_subnet.siem.id
}

output "db_subnet_group_name" {
  description = "Nombre del DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "nat_gateway_ip" {
  description = "IP del NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "vpc_cidr" {
  description = "CIDR de la VPC"
  value       = aws_vpc.main.cidr_block
}
