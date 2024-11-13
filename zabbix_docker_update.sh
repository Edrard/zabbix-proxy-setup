#!/usr/bin/env bash

set -e

docker-compose down

export CONTAINER_VERSION=`cat zabbix/container.version`
export CONTAINER_IMAGE=`cat zabbix/container.image`
if [ -z "$CONTAINER_IMAGE" ]; then
  CONTAINER_IMAGE="zabbix/zabbix-proxy-sqlite3"
fi

if [ "$1" == "-help" ]; then
  echo "Usage: $(basename $0) [ <container-name> [ <container-version> ] ]"
  echo
  echo "Default for container name is 'zabbix-proxy' and version is '${CONTAINER_VERSION}'"
  echo
  exit 0
fi

DIR=`realpath $(dirname $0)`
NAME=${1:-zabbix-proxy}
CONTAINER_VERSION=${2:-${CONTAINER_VERSION}}

docker pull ${CONTAINER_IMAGE}:${CONTAINER_VERSION}


PSK_FILE=zabbix/enc/zabbix_proxy.psk
CERT_FILE=zabbix/enc/zabbix_proxy_cert.pem
KEY_FILE=zabbix/enc/zabbix_proxy_key.pem
CA_FILE=zabbix/enc/zabbix_proxy.ca
START_CMD="docker-entrypoint.sh"

if [ "$(docker ps -a -f name=${NAME} | awk '{print $NF}' | grep -e ^${NAME}$)" ]; then
  echo "Container with name '${NAME}' already exists. Stop and remove old container before creating new one."
  exit 1
elif [ "$(docker ps -a -f name=zabbix-java-gateway | awk '{print $NF}' | grep -e ^zabbix-java-gateway$)" ]; then
  echo "Container with name 'zabbix-java-gateway' already exists. Stop and remove old container before creating new one."
  exit 1
elif [ "$(docker ps -a -f name=zabbix-snmptraps | awk '{print $NF}' | grep -e ^zabbix-snmptraps$)" ]; then
  echo "Container with name 'zabbix-snmptraps' already exists. Stop and remove old container before creating new one."
  exit 1
fi

echo "Creating container [${NAME}] using image [${CONTAINER_IMAGE}:${CONTAINER_VERSION}]."

touch zabbix/snmptraps/snmptraps.log
chmod g+w zabbix/snmptraps/snmptraps.log

docker-compose up --no-start
docker start zabbix-proxy

