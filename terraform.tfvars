# ==========================================
# Configuración General
# ==========================================
environment = "prod"
aws_region  = "us-east-1"

# ==========================================
# Configuración de Red VPC
# ==========================================
vpc_name = "ciberseguridad-vpc"
vpc_cidr = "10.0.0.0/16"

# Subnets públicas (para ALB, Bastion, Wazuh)
vpc_public_subnets = [
  "10.0.1.0/24", # us-east-1a
  "10.0.2.0/24", # us-east-1b
  "10.0.3.0/24"  # us-east-1c
]

# Subnets privadas (para Web Servers)
vpc_private_subnets = [
  "10.0.10.0/24", # us-east-1a
  "10.0.20.0/24", # us-east-1b
  "10.0.30.0/24"  # us-east-1c
]

# Subnets de base de datos (para RDS)
vpc_database_subnets = [
  "10.0.100.0/24", # us-east-1a
  "10.0.101.0/24", # us-east-1b
  "10.0.102.0/24"  # us-east-1c
]

# Subnet para SIEM (Wazuh)
vpc_siem_subnet = "10.0.4.0/24"

# ==========================================
# Configuración de Red y Acceso
# ==========================================
# IMPORTANTE: Cambiar por tu IP pública real
# Puedes obtenerla ejecutando: curl ifconfig.me
my_public_ip = "0.0.0.0/0" # ⚠️ CAMBIAR por tu IP real en formato x.x.x.x/32

# Red on-premise (donde está pfSense)
onpremise_cidr = "192.168.10.0/24" # Ajustar según tu red on-premise

# IP pública de pfSense (para VPN Site-to-Site)
pfsense_public_ip = "" # Dejar vacío si no tienes o llenar con la IP real

# Habilitar VPN Site-to-Site
enable_vpn = false # Cambiar a true cuando tengas la IP de pfSense configurada

# ==========================================
# Configuración de Servidores Web
# ==========================================
webserver_count         = 3
webserver_instance_type = "t3.micro"
webserver_ami_id        = "" # Dejar vacío para usar Amazon Linux 2 automáticamente

# Nombre de la llave SSH (debe existir en AWS)
key_name = "vockey"

# Path para health check del ALB
health_check_path = "/health"

# ==========================================
# Configuración de Base de Datos RDS
# ==========================================
db_engine            = "mysql"
db_engine_version    = "8.0.35"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20
db_name              = "webapp"
db_username          = "admin"

# ⚠️ IMPORTANTE: Cambiar por una contraseña segura
db_password = "ChangeMe123!Secure"

db_backup_retention = 7
db_multi_az         = false # Cambiar a true en producción

# ==========================================
# Configuración de Wazuh SIEM
# ==========================================
wazuh_instance_type        = "t3.medium" # Mínimo recomendado para Wazuh
wazuh_ami_id               = ""          # Dejar vacío para usar Ubuntu 22.04 automáticamente
wazuh_version              = "4.7"
wazuh_enable_public_access = true # Para acceder al dashboard desde internet

# ==========================================
# Configuración de Datadog
# ==========================================
# Obtén tus claves en: https://app.datadoghq.com/organization-settings/api-keys
# Con GitHub Student Pack tienes acceso gratuito
datadog_api_key = ""         # ⚠️ REQUERIDO: Tu API Key de Datadog
datadog_app_key = "" # Opcional pero recomendado
datadog_site    = "datadoghq.com"                            # Para cuenta US, usar "datadoghq.eu" para EU

# ==========================================
# Configuración de CloudWatch
# ==========================================
# Email para recibir alarmas de CloudWatch
alarm_email = "ma.fernandezz@duocuc.cl" # ⚠️ CAMBIAR por tu email real

# ==========================================
# Configuración de Bastion Host
# ==========================================
enable_bastion = true # Habilitar para acceso SSH a instancias privadas

# ==========================================
# Configuración de ALB (Opcional)
# ==========================================
# Para habilitar HTTPS, necesitas un certificado en ACM
enable_alb_https = false
certificate_arn  = "" # ARN del certificado SSL/TLS en ACM
