#!/bin/sh

#Pull image
docker pull ileamo/acari-server

# Network
docker network create acari-network-real

# ***** ZABBIX ******

# Zabbix DB
docker run -t \
  --name zabbix-postgres-server-real \
  --network acari-network-real \
  --restart unless-stopped \
  -e POSTGRES_USER="zabbix" \
  -e POSTGRES_PASSWORD="zabbix" \
  -e POSTGRES_DB="zabbix_pwd" \
  -v /var/lib/postgresql/docker/zabbix-acari-server-real/data:/var/lib/postgresql/data \
  -v /etc/localtime:/etc/localtime:ro \
  -d postgres:11.2-alpine

# Zabbix server
docker run -t \
  --name zabbix-server-pgsql-real \
  --network acari-network-real \
  --restart unless-stopped \
  -e DB_SERVER_HOST="zabbix-postgres-server-real" \
  -e POSTGRES_USER="zabbix" \
  -e POSTGRES_PASSWORD="zabbix" \
  -e POSTGRES_DB="zabbix_pwd" \
  --link zabbix-postgres-server-real:postgres \
  -v /etc/localtime:/etc/localtime:ro \
  -d zabbix/zabbix-server-pgsql:latest

# Zabbix WEB
docker run -t \
  --name zabbix-web-nginx-pgsql-real \
  --network acari-network-real \
  --restart unless-stopped \
  -e DB_SERVER_HOST="zabbix-postgres-server-real" \
  -e POSTGRES_USER="zabbix" \
  -e POSTGRES_PASSWORD="zabbix" \
  -e POSTGRES_DB="zabbix_pwd" \
  -e ZBX_SERVER_NAME="Zabbix NSG" \
  -e PHP_TZ="Europe/Moscow" \
  --link zabbix-postgres-server-real:postgres \
  --link zabbix-server-pgsql-real:zabbix-server \
  -p 11443:443 \
  -v /etc/ssl/acari:/etc/ssl/nginx:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -d zabbix/zabbix-web-nginx-pgsql:latest

docker run -t \
  --name acari-zabbix-agent-real \
  --network acari-network-real \
  --restart unless-stopped \
  -e ZBX_HOSTNAME="acari-server-1" \
  -e ZBX_SERVER_HOST="zabbix-server-pgsql-real" \
  --link zabbix-server-pgsql-real:zabbix-server \
  --privileged \
  -d zabbix/zabbix-agent:latest


# ***** ACARI *****

# PostgreSQL
docker run -t \
  --name acari-server-db-real \
  --network acari-network-real \
  --restart unless-stopped \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=acari_server_prod \
  -v /var/lib/postgresql/docker/acari-server-real/data:/var/lib/postgresql/data \
  -v /etc/localtime:/etc/localtime:ro \
  -d postgres:11.2-alpine


# Server
docker run -t \
  --name acari-server-real \
  --network acari-network-real \
  --restart unless-stopped \
  -e DB_HOST=acari-server-db-real \
  -e ZBX_API_URL="http://zabbix-web-nginx-pgsql-real" \
  -e ZBX_WEB_PORT=11443 \
  -p 51020:50020 \
  -p 51019:50019 \
  -v /etc/ssl/acari:/etc/ssl/acari:ro \
  -v /var/log/acari_server_real:/tmp/app/log \
  -v /etc/localtime:/etc/localtime:ro \
  --link acari-server-db-real \
  --link zabbix-web-nginx-pgsql-real \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  -d ileamo/acari-server foreground
