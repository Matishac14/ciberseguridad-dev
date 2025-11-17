data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ==========================================
# SNS Topic para alarmas
# ==========================================
resource "aws_sns_topic" "alarms" {
  name = "${var.environment}-cloudwatch-alarms"

  tags = {
    Name        = "${var.environment}-alarms"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ==========================================
# Log Groups
# ==========================================
resource "aws_cloudwatch_log_group" "nginx_access" {
  name              = "/aws/ec2/nginx/access"
  retention_in_days = 7

  tags = {
    Name        = "${var.environment}-nginx-access"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "nginx_error" {
  name              = "/aws/ec2/nginx/error"
  retention_in_days = 7

  tags = {
    Name        = "${var.environment}-nginx-error"
    Environment = var.environment
  }
}

# ==========================================
# Dashboard principal
# ==========================================
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-infrastructure-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average", label = "Response Time" }],
            [".", "RequestCount", { stat = "Sum", label = "Request Count" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ALB Performance"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type = "metric"
        x    = 12
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", { stat = "Average", label = "Healthy Hosts" }],
            [".", "UnHealthyHostCount", { stat = "Average", label = "Unhealthy Hosts" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ALB Target Health"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type = "metric"
        x    = 0
        y    = 6
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", { stat = "Average", label = "CPU Usage" }],
            [".", "DatabaseConnections", { stat = "Average", label = "Connections" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "RDS Metrics"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type = "metric"
        x    = 12
        y    = 6
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "FreeableMemory", { stat = "Average", label = "Free Memory" }],
            [".", "FreeStorageSpace", { stat = "Average", label = "Free Storage" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "RDS Resources"
        }
      },
      {
        type = "metric"
        x    = 0
        y    = 12
        width = 24
        height = 6
        properties = {
          metrics = [
            for idx, instance_id in var.instance_ids : [
              "AWS/EC2",
              "CPUUtilization",
              {
                stat = "Average"
                label = "Instance ${idx + 1}"
                dimensions = {
                  InstanceId = instance_id
                }
              }
            ]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "EC2 CPU Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type = "metric"
        x    = 0
        y    = 18
        width = 12
        height = 6
        properties = {
          metrics = [
            ["WebServer", "MEM_USED", { stat = "Average", label = "Memory Usage" }],
            [".", "DISK_USED", { stat = "Average", label = "Disk Usage" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "Web Servers - System Metrics"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type = "metric"
        x    = 12
        y    = 18
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", {
              stat = "Average"
              label = "Wazuh SIEM CPU"
              dimensions = {
                InstanceId = var.wazuh_instance_id
              }
            }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "Wazuh SIEM Performance"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      }
    ]
  })
}

# ==========================================
# Alarmas de ALB
# ==========================================
resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name          = "${var.environment}-alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Alerta cuando hay targets no saludables en el ALB"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = split(":", var.target_group_arn)[5]
    LoadBalancer = split("loadbalancer/", var.alb_arn)[1]
  }

  tags = {
    Name        = "${var.environment}-unhealthy-targets"
    Environment = var.environment
    Severity    = "critical"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  alarm_name          = "${var.environment}-alb-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alerta cuando el tiempo de respuesta del ALB supera 1 segundo"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    LoadBalancer = split("loadbalancer/", var.alb_arn)[1]
  }

  tags = {
    Name        = "${var.environment}-high-response-time"
    Environment = var.environment
    Severity    = "warning"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alerta cuando hay más de 10 errores 5XX en 5 minutos"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = split("loadbalancer/", var.alb_arn)[1]
  }

  tags = {
    Name        = "${var.environment}-5xx-errors"
    Environment = var.environment
    Severity    = "critical"
  }
}

# ==========================================
# Alarmas de RDS
# ==========================================
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name          = "${var.environment}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alerta cuando el CPU de RDS supera el 80%"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  tags = {
    Name        = "${var.environment}-rds-high-cpu"
    Environment = var.environment
    Severity    = "warning"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_high_connections" {
  alarm_name          = "${var.environment}-rds-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alerta cuando las conexiones a RDS superan 80"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  tags = {
    Name        = "${var.environment}-rds-high-connections"
    Environment = var.environment
    Severity    = "warning"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "${var.environment}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5000000000  # 5 GB
  alarm_description   = "Alerta cuando el almacenamiento libre de RDS es menor a 5GB"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  tags = {
    Name        = "${var.environment}-rds-low-storage"
    Environment = var.environment
    Severity    = "critical"
  }
}

# ==========================================
# Alarmas de EC2
# ==========================================
resource "aws_cloudwatch_metric_alarm" "ec2_high_cpu" {
  count               = length(var.instance_ids)
  alarm_name          = "${var.environment}-ec2-${count.index + 1}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "Alerta cuando el CPU de EC2 supera el 85%"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    InstanceId = var.instance_ids[count.index]
  }

  tags = {
    Name        = "${var.environment}-ec2-${count.index + 1}-high-cpu"
    Environment = var.environment
    Severity    = "warning"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  count               = length(var.instance_ids)
  alarm_name          = "${var.environment}-ec2-${count.index + 1}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Alerta cuando falla el status check de la instancia EC2"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    InstanceId = var.instance_ids[count.index]
  }

  tags = {
    Name        = "${var.environment}-ec2-${count.index + 1}-status-check"
    Environment = var.environment
    Severity    = "critical"
  }
}

# ==========================================
# Alarma para Wazuh SIEM
# ==========================================
resource "aws_cloudwatch_metric_alarm" "wazuh_high_cpu" {
  alarm_name          = "${var.environment}-wazuh-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alerta cuando el CPU del servidor Wazuh supera el 80%"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    InstanceId = var.wazuh_instance_id
  }

  tags = {
    Name        = "${var.environment}-wazuh-high-cpu"
    Environment = var.environment
    Severity    = "warning"
  }
}
