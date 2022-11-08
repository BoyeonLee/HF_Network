#!/bin/bash

C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_RESET='\033[0m'

# subinfoln echos in blue color
function infoln() {
  echo -e "${C_YELLOW}${1}${C_RESET}"
}

function subinfoln() {
  echo -e "${C_BLUE}${1}${C_RESET}"
}

# Tear down running network.
# infoln "Tear down running network"
./networkDown.sh

# add PATH to ensure we are picking up the correct binaries
export PATH=${HOME}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/config

# Generate certificates using Fabric CA
# Excute CA containers
infoln "------------- Generating certificates using Fabric CA"
COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
docker-compose -f $COMPOSE_FILE_CA up -d 2>&1
sleep 2

# export env
. execEnv.sh

# Create crypto material using Fabric CA
. scripts/registerEnroll.sh

subinfoln "Create Peer ${ORG_NAME} crypto material"
createPeer

subinfoln "Create Orderer ${ORG_NAME} crypto material"
createOrderer_double

# if only one orderer needs
# subinfoln "Create Orderer ${ORG_NAME} crypto material"
# createOrderer_one

# Generate orderer system channel genesis block.
infoln "------------- Generating Orderer Genesis block"
set -x
configtxgen -profile OrdererGenesis -channelID ourchannel -outputBlock ./system-genesis-block/genesis.block
{ set +x; } 2>/dev/null

# # Bring up the peer and orderer nodes using docker compose.
infoln "------------- Bring up the peer and orderer nodes using docker compose"

COMPOSE_FILES=docker/docker-compose-net.yaml
COMPOSE_FILES_COUCH=docker/docker-compose-couch.yaml
IMAGE_TAG=latest docker-compose -f $COMPOSE_FILES -f $COMPOSE_FILES_COUCH up -d 2>&1

docker ps -a
