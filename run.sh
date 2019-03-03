#!/bin/sh

#Pull images
docker pull ileamo/acari-client
docker pull ileamo/acari-server
docker pull ileamo/acari-server-db:init-25

# Network
docker network create acari-network

# PostgreSQL
docker run --rm -it \
--name acari-server-db \
--network acari-network \
-e POSTGRES_PASSWORD=postgres \
-e POSTGRES_DB=acari_server_prod \
-e PGDATA=/var/lib/postgresql-a/data/pgdata \
-d ileamo/acari-server-db:init-25

# Server
docker run --rm -it \
--name acari-server \
--network acari-network \
-p 50020:50020 \
--cap-add=NET_ADMIN \
--device /dev/net/tun:/dev/net/tun \
-d ileamo/acari-server foreground

# Client
docker run --rm -it \
--name acari-client \
--network acari-network \
--cap-add=NET_ADMIN \
--device /dev/net/tun:/dev/net/tun \
-d ileamo/acari-client
