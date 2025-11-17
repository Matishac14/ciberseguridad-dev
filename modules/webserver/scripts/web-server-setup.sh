#!/bin/bash
set -e

# Variables de entorno
export DB_HOST="${db_endpoint}"
export DB_NAME="${db_name}"
export DB_USER="${db_username}"
export DB_PASS="${db_password}"
export WAZUH_MANAGER="${wazuh_manager_ip}"
export DD_API_KEY="${datadog_api_key}"
export DD_SITE="${datadog_site}"
export ENVIRONMENT="${environment}"
export SERVER_INDEX="${server_index}"

# Log de instalación
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "==== Iniciando configuración del servidor web ===="
echo "Fecha: $(date)"
echo "Hostname: $(hostname)"
echo "Servidor: $SERVER_INDEX"

# Actualizar sistema
echo "Actualizando sistema..."
yum update -y

# Instalar nginx
echo "Instalando nginx..."
amazon-linux-extras install nginx1 -y

# Instalar MySQL client
echo "Instalando MySQL client..."
yum install -y mysql

# Instalar dependencias adicionales
yum install -y wget curl net-tools

# ==========================================
# Configurar Nginx
# ==========================================
echo "Configurando nginx..."

# Crear página de inicio dinámica
cat > /usr/share/nginx/html/index.html <<'HTMLEOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servidor Web - Evaluación Parcial 3</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f4f4f4;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .info {
            background: #e8f4f8;
            padding: 15px;
            border-left: 4px solid #0066cc;
            margin: 10px 0;
        }
        .status {
            display: inline-block;
            padding: 5px 10px;
            background: #28a745;
            color: white;
            border-radius: 4px;
        }
        .metric {
            display: flex;
            justify-content: space-between;
            padding: 10px;
            border-bottom: 1px solid #eee;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Servidor Web Activo</h1>
        <div class="status">✓ Sistema Operativo</div>

        <h2>Información del Servidor</h2>
        <div class="info">
            <div class="metric">
                <span><strong>Hostname:</strong></span>
                <span>HOSTNAME_PLACEHOLDER</span>
            </div>
            <div class="metric">
                <span><strong>Instance ID:</strong></span>
                <span>INSTANCE_ID_PLACEHOLDER</span>
            </div>
            <div class="metric">
                <span><strong>Availability Zone:</strong></span>
                <span>AZ_PLACEHOLDER</span>
            </div>
            <div class="metric">
                <span><strong>Private IP:</strong></span>
                <span>PRIVATE_IP_PLACEHOLDER</span>
            </div>
            <div class="metric">
                <span><strong>Servidor:</strong></span>
                <span>#SERVER_INDEX_PLACEHOLDER</span>
            </div>
        </div>

        <h2>Monitoreo Activo</h2>
        <div class="info">
            <p>✓ CloudWatch Agent</p>
            <p>✓ Datadog Agent</p>
            <p>✓ Wazuh Agent</p>
        </div>

        <h2>Servicios</h2>
        <div class="info">
            <p>✓ Nginx Web Server</p>
            <p>✓ Base de Datos MySQL Conectada</p>
            <p>✓ Logs Centralizados en Wazuh SIEM</p>
        </div>
    </div>
</body>
</html>
HTMLEOF

# Reemplazar placeholders con valores reales
HOSTNAME=$(hostname)
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
AZ=$(ec2-metadata --availability-zone | cut -d " " -f 2)
PRIVATE_IP=$(ec2-metadata --local-ipv4 | cut -d " " -f 2)

sed -i "s/HOSTNAME_PLACEHOLDER/$HOSTNAME/g" /usr/share/nginx/html/index.html
sed -i "s/INSTANCE_ID_PLACEHOLDER/$INSTANCE_ID/g" /usr/share/nginx/html/index.html
sed -i "s/AZ_PLACEHOLDER/$AZ/g" /usr/share/nginx/html/index.html
sed -i "s/PRIVATE_IP_PLACEHOLDER/$PRIVATE_IP/g" /usr/share/nginx/html/index.html
sed -i "s/SERVER_INDEX_PLACEHOLDER/$SERVER_INDEX/g" /usr/share/nginx/html/index.html

# Crear endpoint de health check
echo "OK" > /usr/share/nginx/html/health

# Configurar nginx
cat > /etc/nginx/nginx.conf <<'NGINXEOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        location / {
            index index.html;
        }

        location /health {
            access_log off;
            return 200 "OK\n";
            add_header Content-Type text/plain;
        }

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
}
NGINXEOF

# Iniciar y habilitar nginx
systemctl start nginx
systemctl enable nginx

# ==========================================
# Instalar CloudWatch Agent
# ==========================================
echo "Instalando CloudWatch Agent..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configurar CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'CWCONFIG'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "metrics": {
    "namespace": "WebServer",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {
            "name": "cpu_usage_idle",
            "rename": "CPU_IDLE",
            "unit": "Percent"
          },
          {
            "name": "cpu_usage_iowait",
            "rename": "CPU_IOWAIT",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          {
            "name": "used_percent",
            "rename": "DISK_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "diskio": {
        "measurement": [
          {
            "name": "io_time",
            "rename": "DISK_IO_TIME"
          }
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MEM_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          {
            "name": "tcp_established",
            "rename": "TCP_ESTABLISHED"
          },
          {
            "name": "tcp_time_wait",
            "rename": "TCP_TIME_WAIT"
          }
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          {
            "name": "swap_used_percent",
            "rename": "SWAP_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/ec2/nginx/access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/ec2/nginx/error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
CWCONFIG

# Iniciar CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

# ==========================================
# Instalar Datadog Agent
# ==========================================
echo "Instalando Datadog Agent..."
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=$DD_API_KEY DD_SITE=$DD_SITE bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Configurar tags de Datadog
cat > /etc/datadog-agent/datadog.yaml <<DDCONFIG
api_key: $DD_API_KEY
site: $DD_SITE
hostname: $HOSTNAME
tags:
  - env:$ENVIRONMENT
  - role:webserver
  - server:$SERVER_INDEX
logs_enabled: true
process_config:
  enabled: true
apm_config:
  enabled: true
DDCONFIG

# Configurar integración de nginx en Datadog
cat > /etc/datadog-agent/conf.d/nginx.d/conf.yaml <<DDNGINX
init_config:
instances:
  - nginx_status_url: http://localhost:80/nginx_status/
DDNGINX

# Habilitar logs de nginx en Datadog
cat > /etc/datadog-agent/conf.d/nginx.d/logs.yaml <<DDLOGS
logs:
  - type: file
    path: /var/log/nginx/access.log
    service: nginx
    source: nginx
  - type: file
    path: /var/log/nginx/error.log
    service: nginx
    source: nginx
DDLOGS

# Reiniciar Datadog Agent
systemctl restart datadog-agent

# ==========================================
# Instalar Wazuh Agent
# ==========================================
echo "Instalando Wazuh Agent..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

cat > /etc/yum.repos.d/wazuh.repo <<WAZUHREPO
[wazuh]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=EL-\$releasever - Wazuh
baseurl=https://packages.wazuh.com/4.x/yum/
protect=1
WAZUHREPO

yum install -y wazuh-agent

# Configurar Wazuh Agent
cat > /var/ossec/etc/ossec.conf <<WAZUHCONF
<ossec_config>
  <client>
    <server>
      <address>$WAZUH_MANAGER</address>
      <port>1514</port>
      <protocol>tcp</protocol>
    </server>
    <config-profile>amazon, amazon-linux</config-profile>
    <notify_time>10</notify_time>
    <time-reconnect>60</time-reconnect>
    <auto_restart>yes</auto_restart>
  </client>

  <client_buffer>
    <disabled>no</disabled>
    <queue_size>5000</queue_size>
    <events_per_second>500</events_per_second>
  </client_buffer>

  <logging>
    <log_format>plain</log_format>
  </logging>

  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/messages</location>
  </localfile>

  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/secure</location>
  </localfile>

  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/nginx/access.log</location>
  </localfile>

  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/nginx/error.log</location>
  </localfile>

  <syscheck>
    <disabled>no</disabled>
    <frequency>43200</frequency>
    <directories check_all="yes">/etc,/usr/bin,/usr/sbin</directories>
    <directories check_all="yes">/bin,/sbin,/boot</directories>
  </syscheck>

  <rootcheck>
    <disabled>no</disabled>
  </rootcheck>

  <wodle name="open-scap">
    <disabled>yes</disabled>
  </wodle>

  <wodle name="cis-cat">
    <disabled>yes</disabled>
  </wodle>

  <wodle name="osquery">
    <disabled>yes</disabled>
  </wodle>

  <wodle name="syscollector">
    <disabled>no</disabled>
    <interval>1h</interval>
    <scan_on_start>yes</scan_on_start>
    <hardware>yes</hardware>
    <os>yes</os>
    <network>yes</network>
    <packages>yes</packages>
    <ports all="no">yes</ports>
    <processes>yes</processes>
  </wodle>

  <sca>
    <enabled>yes</enabled>
    <scan_on_start>yes</scan_on_start>
    <interval>12h</interval>
    <skip_nfs>yes</skip_nfs>
  </sca>
</ossec_config>
WAZUHCONF

# Habilitar y arrancar Wazuh Agent
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

# ==========================================
# Configurar variables de entorno
# ==========================================
cat >> /etc/environment <<ENVEOF
DB_HOST=$DB_HOST
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASS=$DB_PASS
ENVIRONMENT=$ENVIRONMENT
ENVEOF

# ==========================================
# Verificación de servicios
# ==========================================
echo "==== Verificando servicios ===="
systemctl status nginx --no-pager
systemctl status amazon-cloudwatch-agent --no-pager
systemctl status datadog-agent --no-pager
systemctl status wazuh-agent --no-pager

echo "==== Configuración completada ===="
echo "Fecha: $(date)"
