#!/bin/sh

#Pull image
docker pull ileamo/acari-server

# Network
docker network create acari-network-real

# PostgreSQL
docker run -t \
--restart unless-stopped \
--name acari-server-real-db \
--network acari-network-real \
-e POSTGRES_PASSWORD=postgres \
-e POSTGRES_DB=acari_server_prod \
-v /var/lib/postgresql/docker/11.2/data:/var/lib/postgresql/data \
-d postgres:11.2

# Migrate & seed
docker run -t \
--restart unless-stopped \
--network acari-network-real \
-e DB_HOST=acari-server-real-db \
--cap-add=NET_ADMIN \
ileamo/acari-server seed

# Server
docker run -t \
--restart unless-stopped \
--name acari-server-real \
--network acari-network-real \
-e DB_HOST=acari-server-real-db \
-p 51020:50020 \
-p 51019:50019 \
-v /var/log/acari_server:/tmp/app/log \
--cap-add=NET_ADMIN \
--device /dev/net/tun:/dev/net/tun \
-d ileamo/acari-server foreground
