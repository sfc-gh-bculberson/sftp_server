#!/bin/bash

if [ ! -f ./sftp_host_rsa_key ]
then
    echo "Generating keypair for SFTP server..."
    ssh-keygen -b 4096 -t rsa -f ./sftp_host_rsa_key -N ''
fi

echo "Building SFTP server image..."

docker pull --platform linux/amd64 atmoz/sftp:latest
docker buildx build --platform linux/amd64 -t ${REPOSITORY_URL}/sftp:multi --push .

