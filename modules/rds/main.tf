resource "aws_db_instance" "main" {
  identifier     = var.identifier
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.allocated_storage * 2
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.username
  password = var.password

  db_subnet_group_name   = var.db_subnet_group
  vpc_security_group_ids = [var.db_sg_id]

  backup_retention_period = var.backup_retention
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  multi_az               = var.multi_az
  publicly_accessible    = false
  skip_final_snapshot    = true
  final_snapshot_identifier = "${var.identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  deletion_protection    = false

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  performance_insights_enabled = true
  performance_insights_retention_period = 7

  monitoring_interval = 60
  monitoring_role_arn = var.monitoring_role_arn

  tags = {
    Name        = var.identifier
    Environment = var.environment
    Monitoring  = "cloudwatch,datadog"
  }

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }
}

resource "aws_cloudwatch_log_group" "rds_error" {
  name              = "/aws/rds/instance/${var.identifier}/error"
  retention_in_days = 7

  tags = {
    Name        = "${var.identifier}-error-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "rds_general" {
  name              = "/aws/rds/instance/${var.identifier}/general"
  retention_in_days = 7

  tags = {
    Name        = "${var.identifier}-general-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "rds_slowquery" {
  name              = "/aws/rds/instance/${var.identifier}/slowquery"
  retention_in_days = 7

  tags = {
    Name        = "${var.identifier}-slowquery-logs"
    Environment = var.environment
  }
}
