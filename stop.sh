#!/bin/sh

docker stop acari-client acari-server acari-server-db
docker stop zabbix-web-nginx-pgsql zabbix-server-pgsql zabbix-postgres-server
