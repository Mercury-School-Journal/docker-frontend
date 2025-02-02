#!/bin/sh

OVPN_DIR="./ovpn"
DOCKER_COMPOSE_AMD64="./docker-compose-amd64.yml"
DOCKER_COMPOSE_ARM64="./docker-compose-arm64.yml"

if [ -d "$OVPN_DIR" ]; then
    OVPN_FILES=$(find "$OVPN_DIR" -maxdepth 1 -name "*.ovpn")

    if [ -n "$OVPN_FILES" ]; then
        OVPN_COUNT=$(echo "$OVPN_FILES" | wc -l)

        if [ "$OVPN_COUNT" -gt 1 ]; then
            echo "Error: More than one .ovpn file found in the directory $OVPN_DIR."
            exit 1
        fi

        OVPN_FILENAME=$(basename "$OVPN_FILES")

        if [ -f ".env" ]; then
            sed -i "s/^OPENVPN_CONFIG=.*/OPENVPN_CONFIG=$OVPN_FILENAME/" .env
        else
            echo "OPENVPN_CONFIG=$OVPN_FILENAME" > .env
        fi

        echo "The OPENVPN_CONFIG variable has been set to: $OVPN_FILENAME"
    else
        echo "No .ovpn files found in the directory $OVPN_DIR."
        exit 1
    fi
else
    echo "The directory $OVPN_DIR does not exist."
    exit 1
fi
if [ ! -f "$DOCKER_COMPOSE_AMD64" ]; then
    echo "Error: $DOCKER_COMPOSE_AMD64 does not exist."
    exit 1
fi

if [ ! -f "$DOCKER_COMPOSE_ARM64" ]; then
    echo "Error: $DOCKER_COMPOSE_ARM64 does not exist."
    exit 1
fi

if [ "$(uname -m)" = "x86_64" ]; then
    docker-compose -f docker-compose-amd64.yml down --rmi all -v
    docker-compose -f docker-compose-amd64.yml up
    docker-compose -f docker-compose-amd64.yml down --rmi all -v
else 
    docker-compose -f docker-compose-arm64.yml down --rmi all -v
    docker-compose -f docker-compose-arm64.yml up
    docker-compose -f docker-compose-arm64.yml down --rmi all -v
fi