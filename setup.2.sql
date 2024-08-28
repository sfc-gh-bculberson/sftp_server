
USE ROLE ACCOUNTADMIN;
GRANT CREATE NETWORK RULE ON SCHEMA SFTP_DB.SFTP_SCHEMA TO ROLE SFTP_ROLE;
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE SFTP_ROLE;

USE ROLE SFTP_ROLE;
USE DATABASE SFTP_DB;
USE SCHEMA SFTP_SCHEMA;

CREATE OR REPLACE NETWORK RULE ngrok_egress_access
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('connect.ngrok-agent.com:443', 'crl.ngrok-agent.com:80');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION ngrok_egress_access_integration
  ALLOWED_NETWORK_RULES = (ngrok_egress_access)
  ENABLED = true;

USE ROLE SFTP_ROLE;
USE DATABASE SFTP_DB;
USE SCHEMA SFTP_SCHEMA;
CREATE SERVICE sftp_service
  IN COMPUTE POOL sftp_compute_pool  
  FROM SPECIFICATION $$
    spec:
      containers:
      - name: sftp
        image: /sftp_db/sftp_schema/sftp_repository/sftp:multi
        args:
         - foo::1001
        volumeMounts:
         - name: stage
           mountPath: /home/foo/stage
      - name: ngrok
        image: /sftp_db/sftp_schema/sftp_repository/ngrok:multi
      volumes:
      - name: stage
        source: "@SFTP_STAGE"
      $$
   EXTERNAL_ACCESS_INTEGRATIONS = (ngrok_egress_access_integration)
   MIN_INSTANCES=1
   MAX_INSTANCES=1;

CALL SYSTEM$GET_SERVICE_STATUS('sftp_service');
CALL SYSTEM$GET_SERVICE_LOGS('sftp_service', '0', 'sftp', 10);
CALL SYSTEM$GET_SERVICE_LOGS('sftp_service', '0', 'ngrok', 10);

ls @SFTP_STAGE;