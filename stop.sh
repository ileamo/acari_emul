#!/bin/sh

docker stop acari-client acari-foo acari-bar acari-baz acari-server-db
docker stop acari-zabbix-agent zabbix-web-nginx-pgsql zabbix-server-pgsql zabbix-postgres-server
