#!/bin/sh

#Pull images
docker pull ileamo/acari-client
docker pull ileamo/acari-server

# Network
docker network create acari-network

# ***** ZABBIX ******
# Zabbix DB
docker run -t \
  --name zabbix-postgres-server \
  --network acari-network \
  --restart unless-stopped \
  -e POSTGRES_USER="zabbix" \
  -e POSTGRES_PASSWORD="zabbix" \
  -e POSTGRES_DB="zabbix_pwd" \
  -v /var/lib/postgresql/docker/zabbix-acari-server/data:/var/lib/postgresql/data \
  -v /etc/localtime:/etc/localtime:ro \
  -d postgres:11.2-alpine

# Zabbix server
docker run -t \
  --name zabbix-server-pgsql \
  --network acari-network \
  --restart unless-stopped \
  -e DB_SERVER_HOST="zabbix-postgres-server" \
  -e POSTGRES_USER="zabbix" \
  -e POSTGRES_PASSWORD="zabbix" \
  -e POSTGRES_DB="zabbix_pwd" \
  --link zabbix-postgres-server:postgres \
  -v /etc/localtime:/etc/localtime:ro \
  -d zabbix/zabbix-server-pgsql:latest

# Zabbix WEB
docker run -t \
  --name zabbix-web-nginx-pgsql \
  --network acari-network \
  --restart unless-stopped \
  -e DB_SERVER_HOST="zabbix-postgres-server" \
  -e POSTGRES_USER="zabbix" \
  -e POSTGRES_PASSWORD="zabbix" \
  -e POSTGRES_DB="zabbix_pwd" \
  -e ZBX_SERVER_NAME="Zabbix NSG" \
  -e PHP_TZ="Europe/Moscow" \
  --link zabbix-postgres-server:postgres \
  --link zabbix-server-pgsql:zabbix-server \
  -p 10080:80 \
  -v /etc/ssl/nginx:/etc/ssl/nginx:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -d zabbix/zabbix-web-nginx-pgsql:latest


# ***** ACARI *****

# PostgreSQL
docker run -t \
  --name acari-server-db \
  --network acari-network \
  --restart unless-stopped \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=acari_server_prod \
  -v /var/lib/postgresql/docker/acari-server/data:/var/lib/postgresql/data \
  -v /etc/localtime:/etc/localtime:ro \
  -d postgres:11.2-alpine

# Server
docker run -t \
  --name acari-server \
  --network acari-network \
  --restart unless-stopped \
  -e DB_HOST=acari-server-db \
  -p 50020:50020 \
  -v /var/log/acari_server:/tmp/app/log \
  -v /etc/localtime:/etc/localtime:ro \
  --link acari-server-db \
  --link zabbix-web-nginx-pgsql \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  -d ileamo/acari-server foreground

# Client
docker run -t \
  --name acari-client \
  --network acari-network \
  --restart unless-stopped \
  -v /var/log/acari_client:/tmp/app/log \
  -v /etc/localtime:/etc/localtime:ro \
  --link acari-server \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  -d ileamo/acari-client
