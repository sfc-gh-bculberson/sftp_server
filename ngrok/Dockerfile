FROM ngrok/ngrok:latest

COPY ./ngrok.yml /etc/ngrok.yml

CMD [ "start", "--all", "--config", "/etc/ngrok.yml" ]