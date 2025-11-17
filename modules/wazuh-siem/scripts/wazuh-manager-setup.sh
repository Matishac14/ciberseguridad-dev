#!/bin/bash
set -e

# Actualizar sistema
apt-get update
apt-get upgrade -y

# Instalar dependencias
apt-get install -y curl apt-transport-https lsb-release gnupg

# Instalar Wazuh Manager
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/${wazuh_version}/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

apt-get update
apt-get install -y wazuh-manager

# Habilitar y arrancar Wazuh Manager
systemctl daemon-reload
systemctl enable wazuh-manager
systemctl start wazuh-manager

# Instalar Filebeat
curl -s https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/elasticsearch.gpg --import && chmod 644 /usr/share/keyrings/elasticsearch.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list

apt-get update
apt-get install -y filebeat

# Descargar configuración de Filebeat para Wazuh
curl -so /etc/filebeat/filebeat.yml https://packages.wazuh.com/${wazuh_version}/tpl/wazuh/filebeat/filebeat.yml
curl -so /etc/filebeat/wazuh-template.json https://raw.githubusercontent.com/wazuh/wazuh/${wazuh_version}/extensions/elasticsearch/7.x/wazuh-template.json
chmod go+r /etc/filebeat/wazuh-template.json

# Instalar módulo Wazuh para Filebeat
curl -s https://packages.wazuh.com/${wazuh_version}/filebeat/wazuh-filebeat-0.2.tar.gz | tar -xvz -C /usr/share/filebeat/module

# Instalar Elasticsearch
apt-get install -y elasticsearch=7.17.13

# Configurar Elasticsearch
cat > /etc/elasticsearch/elasticsearch.yml <<EOF
network.host: 0.0.0.0
node.name: wazuh-node
cluster.initial_master_nodes: ["wazuh-node"]
cluster.name: wazuh-cluster
EOF

# Habilitar y arrancar Elasticsearch
systemctl daemon-reload
systemctl enable elasticsearch
systemctl start elasticsearch

# Esperar a que Elasticsearch inicie
sleep 30

# Configurar índices de Wazuh
filebeat setup --index-management -E output.logstash.enabled=false

# Habilitar y arrancar Filebeat
systemctl enable filebeat
systemctl start filebeat

# Instalar Kibana
apt-get install -y kibana=7.17.13

# Instalar plugin de Wazuh para Kibana
cd /usr/share/kibana
sudo -u kibana bin/kibana-plugin install https://packages.wazuh.com/${wazuh_version}/ui/kibana/wazuh_kibana-${wazuh_version}_7.17.13-1.zip

# Configurar Kibana
cat > /etc/kibana/kibana.yml <<EOF
server.host: "0.0.0.0"
server.port: 443
elasticsearch.hosts: ["http://localhost:9200"]
kibana.defaultAppId: "wazuh"
server.ssl.enabled: true
server.ssl.certificate: /etc/kibana/certs/kibana.crt
server.ssl.key: /etc/kibana/certs/kibana.key
EOF

# Crear certificados autofirmados
mkdir -p /etc/kibana/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/kibana/certs/kibana.key \
  -out /etc/kibana/certs/kibana.crt \
  -subj "/C=CL/ST=Santiago/L=Santiago/O=DUOC/CN=wazuh-siem"

chown -R kibana:kibana /etc/kibana/certs

# Habilitar y arrancar Kibana
systemctl enable kibana
systemctl start kibana

# Configurar firewall UFW
ufw --force enable
ufw allow 22/tcp
ufw allow 443/tcp
ufw allow 55000/tcp
ufw allow 1514:1515/tcp
ufw allow 514/udp

# Configurar syslog para recibir de pfSense
cat >> /var/ossec/etc/ossec.conf <<EOF
  <remote>
    <connection>syslog</connection>
    <port>514</port>
    <protocol>udp</protocol>
    <allowed-ips>0.0.0.0/0</allowed-ips>
  </remote>
EOF

systemctl restart wazuh-manager

# Obtener credenciales
echo "Wazuh Manager instalado correctamente"
echo "Dashboard URL: https://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "Usuario: admin"
echo "Obtener contraseña con: /usr/share/kibana/bin/kibana-encryption-keys generate"
