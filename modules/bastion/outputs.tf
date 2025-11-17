output "instance_id" {
  description = "ID de la instancia bastion"
  value       = aws_instance.bastion.id
}

output "public_ip" {
  description = "IP pública del bastion"
  value       = aws_eip.bastion.public_ip
}

output "private_ip" {
  description = "IP privada del bastion"
  value       = aws_instance.bastion.private_ip
}

output "ssh_command" {
  description = "Comando SSH para conectar al bastion"
  value       = "ssh -i vockey.pem ec2-user@${aws_eip.bastion.public_ip}"
}
