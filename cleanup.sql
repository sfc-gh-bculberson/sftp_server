USE ROLE ACCOUNTADMIN;
DROP INTEGRATION IF EXISTS ngrok_egress_access_integration;
DROP DATABASE IF EXISTS SFTP_DB;
DROP WAREHOUSE IF EXISTS SFTP_WAREHOUSE;
DROP ROLE IF EXISTS SFTP_ROLE;
DROP COMPUTE POOL IF EXISTS sftp_compute_pool;