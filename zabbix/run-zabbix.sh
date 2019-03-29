#!/bin/sh

docker run -t \
      --name zabbix-postgres-server-main \
      --restart unless-stopped \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix" \
      -e POSTGRES_DB="zabbix_pwd" \
      -v /var/lib/postgresql/docker/zabbix-main/data:/var/lib/postgresql/data \
      -v /etc/localtime:/etc/localtime:ro \
      -d postgres:11.2-alpine

docker run -t \
      --name zabbix-server-pgsql-main \
      --restart unless-stopped \
      -e DB_SERVER_HOST="zabbix-postgres-server-main" \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix" \
      -e POSTGRES_DB="zabbix_pwd" \
      --link zabbix-postgres-server-main:postgres \
      -p 10051:10051 \
      -v /etc/localtime:/etc/localtime:ro \
      -d zabbix/zabbix-server-pgsql:latest

docker run -t \
      --name zabbix-web-nginx-pgsql-main \
      --restart unless-stopped \
      -e DB_SERVER_HOST="zabbix-postgres-server-main" \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix" \
      -e POSTGRES_DB="zabbix_pwd" \
      -e ZBX_SERVER_NAME="Zabbix NSG" \
      -e PHP_TZ="Europe/Moscow" \
      --link zabbix-postgres-server-main:postgres \
      --link zabbix-server-pgsql-main:zabbix-server \
      -p 4443:443 \
      -p 4080:80 \
      -v /etc/ssl/acari:/etc/ssl/nginx:ro \
      -v /etc/localtime:/etc/localtime:ro \
      -d zabbix/zabbix-web-nginx-pgsql:latest
