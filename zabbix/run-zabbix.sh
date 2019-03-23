#!/bin/sh

docker run -t --rm \
      --name zabbix-postgres-server-main \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix" \
      -e POSTGRES_DB="zabbix" \
      -v /var/lib/postgresql/docker/zabbix-main/data:/var/lib/postgresql/data \
      -v /etc/localtime:/etc/localtime:ro \
      -d postgres:11.2-alpine

docker run -t --rm \
      --name zabbix-server-pgsql-main \
      -e DB_SERVER_HOST="zabbix-postgres-server-main" \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix" \
      -e POSTGRES_DB="zabbix" \
      --link zabbix-postgres-server-main:postgres \
      -p 10051:10051 \
      -v /etc/localtime:/etc/localtime:ro \
      -d zabbix/zabbix-server-pgsql:latest

docker run -t --rm \
      --name zabbix-web-nginx-pgsql-main \
      -e DB_SERVER_HOST="zabbix-postgres-server-main" \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix" \
      -e POSTGRES_DB="zabbix" \
      -e ZBX_SERVER_NAME="Zabbix NSG" \
      --link zabbix-postgres-server-main:postgres \
      --link zabbix-server-pgsql-main:zabbix-server \
      -p 80:80 \
      -v /etc/ssl/nginx:/etc/ssl/nginx:ro \
      -v /etc/localtime:/etc/localtime:ro \
      -d zabbix/zabbix-web-nginx-pgsql:latest
