data "aws_availability_zones" "available" {
  state = "available"
}

# Obtener el rol LabRole existente
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Módulo VPC
module "vpc" {
  source = "./modules/vpc"

  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  availability_zones  = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets      = var.vpc_public_subnets
  private_subnets     = var.vpc_private_subnets
  database_subnets    = var.vpc_database_subnets
  siem_subnet         = var.vpc_siem_subnet
  environment         = var.environment
}

# Módulo Security Groups
module "security_groups" {
  source = "./modules/security-groups"

  vpc_id           = module.vpc.vpc_id
  my_public_ip     = var.my_public_ip
  onpremise_cidr   = var.onpremise_cidr
  environment      = var.environment
}

# Módulo VPN Gateway para conexión on-premise
module "vpn_gateway" {
  source = "./modules/vpn-gateway"
  count  = var.enable_vpn ? 1 : 0

  vpc_id               = module.vpc.vpc_id
  customer_gateway_ip  = var.pfsense_public_ip
  onpremise_cidr       = var.onpremise_cidr
  environment          = var.environment
}

# Módulo ALB
module "alb" {
  source = "./modules/alb"

  name               = "${var.environment}-web-alb"
  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.vpc.public_subnets
  alb_sg_id          = module.security_groups.alb_sg_id
  environment        = var.environment
  health_check_path  = var.health_check_path
}

# Módulo Web Server
module "webserver" {
  source = "./modules/webserver"

  instance_count       = var.webserver_count
  instance_type        = var.webserver_instance_type
  ami_id               = var.webserver_ami_id
  key_name             = var.key_name
  private_subnets      = module.vpc.private_subnets
  web_sg_id            = module.security_groups.web_sg_id
  target_group_arn     = module.alb.target_group_arn
  iam_role_name        = data.aws_iam_role.lab_role.name
  environment          = var.environment
  db_endpoint          = module.rds.db_endpoint
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  wazuh_manager_ip     = module.wazuh_siem.wazuh_manager_private_ip
  datadog_api_key      = var.datadog_api_key
  datadog_site         = var.datadog_site
}

# Módulo RDS
module "rds" {
  source = "./modules/rds"

  identifier          = "${var.environment}-webapp-db"
  engine              = var.db_engine
  engine_version      = var.db_engine_version
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  db_subnet_group     = module.vpc.db_subnet_group_name
  db_sg_id            = module.security_groups.db_sg_id
  environment         = var.environment
  backup_retention    = var.db_backup_retention
  multi_az            = var.db_multi_az
}

# Módulo Wazuh SIEM
module "wazuh_siem" {
  source = "./modules/wazuh-siem"

  instance_type          = var.wazuh_instance_type
  ami_id                 = var.wazuh_ami_id
  key_name               = var.key_name
  siem_subnet            = module.vpc.siem_subnet
  wazuh_sg_id            = module.security_groups.wazuh_sg_id
  iam_role_name          = data.aws_iam_role.lab_role.name
  environment            = var.environment
  wazuh_version          = var.wazuh_version
  enable_public_access   = var.wazuh_enable_public_access
}

# Módulo CloudWatch
module "cloudwatch" {
  source = "./modules/cloudwatch"

  alb_arn             = module.alb.alb_arn
  alb_name            = module.alb.alb_name
  target_group_arn    = module.alb.target_group_arn
  instance_ids        = module.webserver.instance_ids
  db_instance_id      = module.rds.db_instance_id
  wazuh_instance_id   = module.wazuh_siem.wazuh_instance_id
  environment         = var.environment
  alarm_email         = var.alarm_email
}

# Módulo Datadog
module "datadog" {
  source = "./modules/datadog"

  datadog_api_key     = var.datadog_api_key
  datadog_app_key     = var.datadog_app_key
  datadog_site        = var.datadog_site
  environment         = var.environment

  monitor_alb         = true
  monitor_rds         = true
  monitor_ec2         = true
  monitor_wazuh       = true

  alb_arn             = module.alb.alb_arn
  db_instance_id      = module.rds.db_instance_id
  ec2_instance_ids    = concat(module.webserver.instance_ids, [module.wazuh_siem.wazuh_instance_id])
}

# Módulo Bastion
module "bastion" {
  source = "./modules/bastion"
  count  = var.enable_bastion ? 1 : 0

  instance_type   = "t3.micro"
  ami_id          = var.webserver_ami_id
  key_name        = var.key_name
  public_subnet   = module.vpc.public_subnets[0]
  bastion_sg_id   = module.security_groups.bastion_sg_id
  iam_role_name   = data.aws_iam_role.lab_role.name
  environment     = var.environment
}
