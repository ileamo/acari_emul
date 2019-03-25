#!/bin/sh

docker start zabbix-postgres-server zabbix-server-pgsql zabbix-web-nginx-pgsql acari-zabbix-agent
docker start acari-server-db acari-server acari-client
