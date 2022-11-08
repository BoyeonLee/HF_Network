#!/bin/bash

COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
# COMPOSE_FILES=docker/docker-compose-net.yaml
# COMPOSE_FILES_COUCH=docker/docker-compose-couch.yaml

# docker-compose -f $COMPOSE_FILE_CA -f $COMPOSE_FILES -f $COMPOSE_FILES_COUCH down --volumes --remove-orphans
docker-compose -f $COMPOSE_FILE_CA down --volumes --remove-orphans

if [ -d "organizations/CAs" ]; then
    sudo rm -Rf organizations/CAs/*
fi

if [ -d "organizations/peerOrgs" ]; then
    sudo rm -Rf organizations/peerOrgs
    sudo rm -Rf organizations/ordererOrgs
fi

# cleen up the MSP directory
if [ -d "organizations/peerOrgs" ]; then
    sudo rm -Rf organizations/peerOrgs
    sudo rm -Rf organizations/ordererOrgs
    sudo rm -Rf organizations/CAs/*
fi

# cleen up the genesis block directory
if [ -d "system-genesis-block" ]; then
    rm -Rf system-genesis-block/*
fi
