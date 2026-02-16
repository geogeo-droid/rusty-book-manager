#!/bin/bash

BASE_NAME=$(basename `pwd`)

REDIS_NETWORK="${BASE_NAME}_default"
REDIS_SERVICE_NAME=redis-cluster

echo $BASE_NAME
echo $REDIS_NETWORK

REDIS_PORT=6379
CLUSTER_REPLICAS=1

NODES=`docker network inspect ${REDIS_NETWORK} | jq ".[0].Containers | .[] | select(.Name | startswith(\"${BASE_NAME}-redis-cluster\")) | .IPv4Address" | perl -wp -e 's!"(.+)/.+"\r?\n!$1:6379 !g'`

cargo make compose exec ${REDIS_SERVICE_NAME} bash -c "yes yes | redis-cli --cluster create ${NODES} --cluster-replicas ${CLUSTER_REPLICAS}"

cargo make compose exec redis-cluster redis-cli cluster nodes

cargo make compose logs redis-cluster -f
