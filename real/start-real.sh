#!/bin/sh

docker start acari-server-real-db acari-server-real

docker start zabbix-postgres-server-real zabbix-server-pgsql-real zabbix-web-nginx-pgsql-real acari-zabbix-agent-real
docker start acari-server-db-real acari-server-real
