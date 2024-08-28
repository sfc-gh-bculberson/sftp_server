USE ROLE ACCOUNTADMIN;

CREATE ROLE sftp_role;

CREATE DATABASE IF NOT EXISTS sftp_db;
GRANT OWNERSHIP ON DATABASE sftp_db TO ROLE sftp_role COPY CURRENT GRANTS;

CREATE OR REPLACE WAREHOUSE sftp_warehouse WITH
  WAREHOUSE_SIZE='X-SMALL';
GRANT USAGE ON WAREHOUSE sftp_warehouse TO ROLE sftp_role;

GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE sftp_role;

CREATE COMPUTE POOL sftp_compute_pool
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = CPU_X64_XS;
GRANT USAGE, MONITOR ON COMPUTE POOL sftp_compute_pool TO ROLE sftp_role;

GRANT ROLE sftp_role TO USER BCULBERSON;

USE ROLE sftp_role;
USE DATABASE sftp_db;
USE WAREHOUSE sftp_warehouse;

CREATE SCHEMA sftp_schema;
CREATE IMAGE REPOSITORY IF NOT EXISTS sftp_repository;
CREATE OR REPLACE STAGE sftp_stage ENCRYPTION = (type = 'SNOWFLAKE_SSE');

SHOW IMAGE REPOSITORIES;

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
DROP SERVICE sftp_service;
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