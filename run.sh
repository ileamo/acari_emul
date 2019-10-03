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
  -p 10443:443 \
  -v /etc/ssl/acari:/etc/ssl/nginx:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -d zabbix/zabbix-web-nginx-pgsql:latest

docker run -t \
  --name acari-zabbix-agent \
  --network acari-network \
  --restart unless-stopped \
  -e ZBX_HOSTNAME="acari-server-1" \
  -e ZBX_SERVER_HOST="zabbix-server-pgsql" \
  --link zabbix-server-pgsql:zabbix-server \
  --privileged \
  -d zabbix/zabbix-agent:latest


# ***** ACARI *****

# PostgreSQL
docker run -t \
  --name acari-server-db \
  --network acari-network \
  --restart unless-stopped \
  -e POSTGRESQL_REPLICATION_MODE=master \
  -e POSTGRESQL_USERNAME=postgres \
  -e POSTGRESQL_PASSWORD=postgres \
  -e POSTGRESQL_DATABASE=acari_server_prod \
  -e POSTGRESQL_REPLICATION_USER=postgres \
  -e POSTGRESQL_REPLICATION_PASSWORD=postgres \
  -v /var/lib/postgresql/docker/acari-server:/bitnami/postgresql \
  -v /etc/localtime:/etc/localtime:ro \
  -d bitnami/postgresql:latest


# Migrate DB
docker run -t \
  --network acari-network \
  -e DB_HOST=acari-server-db \
  --cap-add=NET_ADMIN \
  ileamo/acari-server migrate

# Server foo
# --name and --hostname must be the same
docker run -t \
  --name acari-foo \
  --hostname acari-foo \
  --network acari-network \
  --restart unless-stopped \
  -e DB_HOST=acari-server-db \
  -e DB_HOSTS_RW="acari-server-db" \
  -e DB_HOSTS_RO="acari-server-db" \
  -e ZBX_API_URL="http://zabbix-web-nginx-pgsql" \
  -e ZBX_WEB_PORT=10443 \
  -e ZBX_SND_HOST="zabbix-server-pgsql" \
  -p 443:50443 \
  -p 51019:50019 \
  -v /etc/ssl/acari:/etc/ssl/acari:ro \
  -v /var/log/acari_foo:/var/log \
  -v /etc/localtime:/etc/localtime:ro \
  --link acari-server-db \
  --link zabbix-web-nginx-pgsql \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  -d ileamo/acari-server

# Server bar
# --name and --hostname must be the same
docker run -t \
  --name acari-bar \
  --hostname acari-bar \
  --network acari-network \
  --restart unless-stopped \
  -e DB_HOST=acari-server-db \
  -e DB_HOSTS_RW="acari-server-db" \
  -e DB_HOSTS_RO="acari-server-db" \
  -e ZBX_API_URL="http://zabbix-web-nginx-pgsql" \
  -e ZBX_WEB_PORT=10443 \
  -e ZBX_SND_HOST="zabbix-server-pgsql" \
  -p 52443:50443 \
  -p 52019:50019 \
  -v /etc/ssl/acari:/etc/ssl/acari:ro \
  -v /var/log/acari_bar:/var/log \
  -v /etc/localtime:/etc/localtime:ro \
  --link acari-server-db \
  --link zabbix-web-nginx-pgsql \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  -d ileamo/acari-server

# Server baz
# --name and --hostname must be the same
docker run -t \
  --name acari-baz \
  --hostname acari-baz \
  --network acari-network \
  --restart unless-stopped \
  -e DB_HOST=acari-server-db \
  -e DB_HOSTS_RW="acari-server-db" \
  -e DB_HOSTS_RO="acari-server-db" \
  -e ZBX_API_URL="http://zabbix-web-nginx-pgsql" \
  -e ZBX_WEB_PORT=10443 \
  -e ZBX_SND_HOST="zabbix-server-pgsql" \
  -p 53443:50443 \
  -p 53019:50019 \
  -v /etc/ssl/acari:/etc/ssl/acari:ro \
  -v /var/log/acari_baz:/var/log \
  -v /etc/localtime:/etc/localtime:ro \
  --link acari-server-db \
  --link zabbix-web-nginx-pgsql \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  -d ileamo/acari-server

# Client
docker run -t \
  --name acari-client \
  --network acari-network \
  --restart unless-stopped \
  -e SRV_HOST="acari-server" \
  -v /var/log/acari_client:/var/log \
  -v /etc/localtime:/etc/localtime:ro \
  --link acari-server \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  -d ileamo/acari-client
