#!/bin/sh

cat ngrok.yml.tpl | sed "s/NGROK_AUTHTOKEN/$NGROK_AUTHTOKEN/g" > ngrok.yml
docker buildx build --platform linux/arm64/v8,linux/amd64 -t ${REPOSITORY_URL}/ngrok:multi --push .
