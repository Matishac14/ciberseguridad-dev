terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

resource "datadog_dashboard" "main" {
  title       = "${var.environment} - Infraestructura AWS"
  description = "Dashboard principal de monitoreo"
  layout_type = "ordered"

  widget {
    group_definition {
      title       = "ALB Metrics"
      layout_type = "ordered"

      widget {
        timeseries_definition {
          title = "ALB Request Count"
          request {
            q            = "sum:aws.applicationelb.request_count{*}.as_count()"
            display_type = "line"
          }
        }
      }

      widget {
        timeseries_definition {
          title = "ALB Response Time"
          request {
            q            = "avg:aws.applicationelb.target_response_time{*}"
            display_type = "line"
          }
        }
      }
    }
  }

  widget {
    group_definition {
      title       = "RDS Metrics"
      layout_type = "ordered"

      widget {
        timeseries_definition {
          title = "RDS CPU Utilization"
          request {
            q            = "avg:aws.rds.cpuutilization{*}"
            display_type = "line"
          }
        }
      }

      widget {
        timeseries_definition {
          title = "RDS Database Connections"
          request {
            q            = "avg:aws.rds.database_connections{*}"
            display_type = "line"
          }
        }
      }
    }
  }

  widget {
    group_definition {
      title       = "EC2 Metrics"
      layout_type = "ordered"

      widget {
        timeseries_definition {
          title = "EC2 CPU Utilization"
          request {
            q            = "avg:aws.ec2.cpuutilization{*} by {host}"
            display_type = "line"
          }
        }
      }
    }
  }
}

resource "datadog_monitor" "alb_5xx_errors" {
  count   = var.monitor_alb ? 1 : 0
  name    = "${var.environment} - ALB High 5XX Errors"
  type    = "metric alert"
  message = "ALB esta generando muchos errores 5XX"

  query = "sum(last_5m):sum:aws.applicationelb.httpcode_target_5xx{*}.as_count() > 100"

  monitor_thresholds {
    critical = 100
    warning  = 50
  }

  notify_no_data    = false
  renotify_interval = 60

  tags = ["environment:${var.environment}", "service:alb"]
}

resource "datadog_monitor" "rds_cpu" {
  count   = var.monitor_rds ? 1 : 0
  name    = "${var.environment} - RDS High CPU"
  type    = "metric alert"
  message = "RDS CPU usage is high"

  query = "avg(last_10m):avg:aws.rds.cpuutilization{*} > 80"

  monitor_thresholds {
    critical = 80
    warning  = 70
  }

  tags = ["environment:${var.environment}", "service:rds"]
}

resource "datadog_monitor" "ec2_cpu" {
  count   = var.monitor_ec2 ? 1 : 0
  name    = "${var.environment} - EC2 High CPU"
  type    = "metric alert"
  message = "EC2 instance CPU usage is high"

  query = "avg(last_5m):avg:aws.ec2.cpuutilization{*} by {host} > 85"

  monitor_thresholds {
    critical = 85
    warning  = 75
  }

  tags = ["environment:${var.environment}", "service:ec2"]
}

data "aws_caller_identity" "current" {}
