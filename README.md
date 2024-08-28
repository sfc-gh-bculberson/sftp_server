# SFTP Server to READ/WRITE to a Snowflake Stage

This project is a demo to show how Snowflake Container Services with ngrok could be used to support a legacy solution which requires SFTP protocol.

## INSTRUCTIONS

Run the sql from setup.1.sql in the Snowflake Account. 

## BUILD & PUSH

Set environment variables for NGROK_AUTHTOKEN and REPOSITORY_URL before building the containers.


```bash
export NGROK_AUTHTOKEN=<REDACTED>
export REPOSITORY_URL=<REDACTED>
pushd ngrok && ./build.sh && popd
pushd sftp && ./build.sh && popd
```

## CREATE NETWORK RULES & SERVICE

Run the rest of the setup.2.sql to create the service.

The IP and Port of the sftp server will be available in the service logs as well as in the ngrok portal.
