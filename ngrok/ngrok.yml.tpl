version: 2

authtoken: NGROK_AUTHTOKEN
log_level: debug
log_format: json
log: stdout

tunnels:
  sftp:
    proto: tcp
    addr: localhost:22
    # IP restriction is a paid feature
    # ip_restriction:
    #   allow_cidrs: [IP_ADDRESS/32]