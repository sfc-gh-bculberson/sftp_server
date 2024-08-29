#!/bin/sh

IP_ADDRESS=`curl ipinfo.io/ip`
cat ngrok.yml.tpl | sed "s/NGROK_AUTHTOKEN/$NGROK_AUTHTOKEN/g" | sed "s/IP_ADDRESS/$IP_ADDRESS/g" > ngrok.yml
docker buildx build --platform linux/arm64/v8,linux/amd64 -t ${REPOSITORY_URL}/ngrok:multi --push .
