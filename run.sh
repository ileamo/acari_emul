#!/bin/sh

#Pull images
docker pull ileamo/acari-client
docker pull ileamo/acari-server
docker pull ileamo/acari-server-db:init-25

# Network
docker network create acari-network

# ***** ZABBIX ******
# Zabbix DB
docker run -t \
  --name zabbix-postgres-server \
  --network acari-network \
  -e POSTGRES_USER="zabbix" \
  -e POSTGRES_PASSWORD="zabbix" \
  -e POSTGRES_DB="zabbix_pwd" \
  -v /var/lib/postgresql/docker/zabbix/data:/var/lib/postgresql/data \
  -v /etc/localtime:/etc/localtime:ro \
  -d postgres:latest

# Zabbix server
docker run -t \
  --name zabbix-server-pgsql \
  --network acari-network \
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
  -e DB_SERVER_HOST="zabbix-postgres-server" \
  -e POSTGRES_USER="zabbix" \
  -e POSTGRES_PASSWORD="zabbix" \
  -e POSTGRES_DB="zabbix_pwd" \
  -e ZBX_SERVER_NAME="Zabbix NSG" \
  --link zabbix-postgres-server:postgres \
  --link zabbix-server-pgsql:zabbix-server \
  -p 10080:80 \
  -v /etc/ssl/nginx:/etc/ssl/nginx:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -d zabbix/zabbix-web-nginx-pgsql:latest



# PostgreSQL
docker run --rm -it \
--name acari-server-db \
--network acari-network \
-e POSTGRES_PASSWORD=postgres \
-e POSTGRES_DB=acari_server_prod \
-e PGDATA=/var/lib/postgresql-a/data/pgdata \
-v /etc/localtime:/etc/localtime:ro \
-d ileamo/acari-server-db:init-25

# Server
docker run --rm -it \
--name acari-server \
--network acari-network \
-e DB_HOST=acari-server-db \
-p 50020:50020 \
-v /var/log/acari_server:/tmp/app/log \
-v /etc/localtime:/etc/localtime:ro \
--cap-add=NET_ADMIN \
--device /dev/net/tun:/dev/net/tun \
-d ileamo/acari-server foreground

# Client
docker run --rm -it \
--name acari-client \
--network acari-network \
-v /var/log/acari_client:/tmp/app/log \
-v /etc/localtime:/etc/localtime:ro \
--cap-add=NET_ADMIN \
--device /dev/net/tun:/dev/net/tun \
-d ileamo/acari-client
