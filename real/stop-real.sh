#!/bin/sh

docker stop acari-server-real acari-server-db-real
docker stop acari-zabbix-agent-real zabbix-web-nginx-pgsql-real zabbix-server-pgsql-real zabbix-postgres-server-real
