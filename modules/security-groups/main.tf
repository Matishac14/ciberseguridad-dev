# Security Group para ALB
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group para ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP desde internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS desde internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Todo tráfico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }
}

# Security Group para Web Servers
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Security group para servidores web"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP desde ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "HTTPS desde ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Todo tráfico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
  }
}

# Security Group para RDS
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Security group para RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL desde web servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "Todo tráfico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
  }
}

# Security Group para Wazuh SIEM
resource "aws_security_group" "wazuh" {
  name        = "${var.environment}-wazuh-sg"
  description = "Security group para Wazuh Manager"
  vpc_id      = var.vpc_id

  # Wazuh Dashboard (HTTPS)
  ingress {
    description = "HTTPS Dashboard desde internet y on-premise"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat(
      [var.my_public_ip],
        var.onpremise_cidr != "" ? [var.onpremise_cidr] : []
    )
  }

  # Wazuh API
  ingress {
    description = "Wazuh API desde on-premise"
    from_port   = 55000
    to_port     = 55000
    protocol    = "tcp"
    cidr_blocks = var.onpremise_cidr != "" ? [var.onpremise_cidr] : []
  }

  # Wazuh Agent Communication
  ingress {
    description     = "Wazuh Agents desde web servers"
    from_port       = 1514
    to_port         = 1515
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  # Syslog desde on-premise
  ingress {
    description = "Syslog desde on-premise (pfSense)"
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = var.onpremise_cidr != "" ? [var.onpremise_cidr] : []
  }

  egress {
    description = "Todo tráfico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-wazuh-sg"
    Environment = var.environment
    Purpose     = "SIEM"
  }
}

# Security Group para Bastion
resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion-sg"
  description = "Security group para bastion host"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH desde mi IP y on-premise"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = concat(
      [var.my_public_ip],
        var.onpremise_cidr != "" ? [var.onpremise_cidr] : []
    )
  }

  egress {
    description = "Todo tráfico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-bastion-sg"
    Environment = var.environment
  }
}

# Reglas adicionales
resource "aws_security_group_rule" "web_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.web.id
  description              = "SSH desde bastion"
}

resource "aws_security_group_rule" "wazuh_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.wazuh.id
  description              = "SSH desde bastion"
}

resource "aws_security_group_rule" "db_access_from_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.db.id
  description              = "MySQL desde bastion"
}

# Wazuh puede monitorear RDS logs
resource "aws_security_group_rule" "wazuh_to_web" {
  type                     = "ingress"
  from_port                = 1514
  to_port                  = 1515
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.wazuh.id
  security_group_id        = aws_security_group.web.id
  description              = "Wazuh monitoring"
}
