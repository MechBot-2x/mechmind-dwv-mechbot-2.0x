-- En postgres-hardening.sql
ALTER SYSTEM SET ssl = 'on';
ALTER SYSTEM SET password_encryption = 'scram-sha-256';
CREATE ROLE mechbot_rw WITH LOGIN PASSWORD '${VAULT_DB_PWD}' NOINHERIT;
