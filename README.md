# Cheese Infra Terraform

Este proyecto utiliza Terraform para desplegar una arquitectura web escalable y segura en AWS que aloja una aplicación de quesos.

## Estructura del proyecto

├── main.tf              # Invocación de módulos principales
├── providers.tf         # Configuración del proveedor AWS
├── variables.tf         # Variables globales del proyecto
├── terraform.tfvars     # Valores específicos de la infraestructura
├── outputs.tf           # Salidas del proyecto
├── modules              # Módulos reutilizables de Terraform
│   ├── vpc              # Módulo para crear VPC, subredes e Internet Gateway
│   ├── security_group   # Módulo para configurar Security Groups (ALB y EC2)
│   ├── ec2              # Módulo para lanzar instancias EC2 con Docker
│   └── alb              # Módulo para crear un Application Load Balancer

## Despliegue

1. terraform init
2. terraform validate
3. terraform plan
4. terraform apply

## Detalles

- **VPC módulo**: Crea VPC con subredes públicas en distintas AZs y tabla de ruteo.
- **Security Group módulo**: Define SG para ALB (puerto 80) y EC2 (HTTP desde ALB y SSH desde IP).
- **EC2 módulo**: Lanza instancias con Amazon Linux 2, instala Docker y corre contenedores de quesos en el puerto 80.
- **ALB módulo**: Configura un Application Load Balancer con listener HTTP y target group HTTP.
- **Attachments**: Asocia instancias EC2 al target group para balanceo de carga.
