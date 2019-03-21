#!/bin/sh

docker run -t --rm \
      --name zabbix-postgres-server \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix" \
      -e POSTGRES_DB="zabbix_pwd" \
      -v /var/lib/postgresql/docker/zabbix/data:/var/lib/postgresql/data \
      -v /etc/localtime:/etc/localtime:ro \
      -d postgres:latest

docker run -t --rm \
      --name zabbix-server-pgsql \
      -e DB_SERVER_HOST="zabbix-postgres-server" \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix" \
      -e POSTGRES_DB="zabbix_pwd" \
      --link zabbix-postgres-server:postgres \
      -p 10051:10051 \
      -v /etc/localtime:/etc/localtime:ro \
      -d zabbix/zabbix-server-pgsql:latest

docker run -t --rm \
      --name zabbix-web-nginx-pgsql \
      -e DB_SERVER_HOST="zabbix-postgres-server" \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix" \
      -e POSTGRES_DB="zabbix_pwd" \
      -e ZBX_SERVER_NAME="Zabbix NSG" \
      --link zabbix-postgres-server:postgres \
      --link zabbix-server-pgsql:zabbix-server \
      -p 80:80 \
      -p 10080:80 \
      -v /etc/ssl/nginx:/etc/ssl/nginx:ro \
      -v /etc/localtime:/etc/localtime:ro \
      -d zabbix/zabbix-web-nginx-pgsql:latest
