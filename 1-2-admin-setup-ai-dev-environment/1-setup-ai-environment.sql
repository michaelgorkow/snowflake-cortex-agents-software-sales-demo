-- ---------------------------------------------------------
-- Setup AI Development Environment
-- ---------------------------------------------------------
-- This script sets up the initial Snowflake environment for the demo.
-- It creates the databases, schemas, warehouse, network/API integrations,
-- role with required privileges, and a new user with all privileges
-- required to create the entire demo setup.
--
-- NOTE: This script must be run with admin privileges (ACCOUNTADMIN)
-- and should be executed as the VERY FIRST STEP to bootstrap the demo.
-- Once the script finished, login with the newly created user.
-- ---------------------------------------------------------

USE ROLE ACCOUNTADMIN;

-- ---------------------------------------------------------
-- 1. Databases & Schemas
-- ---------------------------------------------------------

-- Create Database for AI Development
CREATE DATABASE IF NOT EXISTS SOFTWARE_SALES_DEMO_DB;

-- Create Database for Snowflake Intelligence Agents
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;

-- ---------------------------------------------------------
-- 2. Core Infrastructure
-- ---------------------------------------------------------

-- Create a warehouse
CREATE WAREHOUSE IF NOT EXISTS SOFTWARE_SALES_DEMO_WH WITH 
  WAREHOUSE_SIZE='X-SMALL' 
  AUTO_SUSPEND=60 
  AUTO_RESUME=TRUE
  GENERATION = '2';

-- ---------------------------------------------------------
-- 3. Networking & Integrations
-- ---------------------------------------------------------

-- Allow cross-region access for Cortex
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';

-- Create External Access (Egress)
CREATE NETWORK RULE IF NOT EXISTS software_sales_demo_external_access_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('0.0.0.0:80', '0.0.0.0:443');

CREATE EXTERNAL ACCESS INTEGRATION IF NOT EXISTS software_sales_demo_external_access_integration
  ALLOWED_NETWORK_RULES = (software_sales_demo_external_access_rule)
  ENABLED = true;

-- Create the API integration with Github
CREATE API INTEGRATION IF NOT EXISTS SOFTWARE_SALES_DEMO_GITHUB_API_INTEGRATION
   API_PROVIDER = git_https_api
   API_ALLOWED_PREFIXES = ('https://github.com/')
   API_USER_AUTHENTICATION = (
      TYPE = snowflake_github_app
   )
   ENABLED = TRUE;

-- Create Slack API Integration
DROP API INTEGRATION software_sales_demo_slack_mcp_integration;
CREATE API INTEGRATION software_sales_demo_slack_mcp_integration
  API_PROVIDER = external_mcp
  API_ALLOWED_PREFIXES = ('https://mcp.slack.com')
  API_USER_AUTHENTICATION = (
    TYPE = OAUTH2
    OAUTH_CLIENT_ID = '<slack-client-id>'
    OAUTH_CLIENT_SECRET = '<slack-client-secret>'
    OAUTH_TOKEN_ENDPOINT = 'https://slack.com/api/oauth.v2.user.access'
    OAUTH_AUTHORIZATION_ENDPOINT = 'https://slack.com/oauth/v2_user/authorize'
    OAUTH_CLIENT_AUTH_METHOD = CLIENT_SECRET_POST
    OAUTH_ALLOWED_SCOPES = ('search:read')
  )
  ENABLED = TRUE;

-- Create Slack External MCP Server
CREATE OR REPLACE EXTERNAL MCP SERVER software_sales_demo_slack_mcp_server
  WITH DISPLAY_NAME = 'Slack'
  URL = 'https://mcp.slack.com/mcp'
  API_INTEGRATION = software_sales_demo_slack_mcp_integration;

-- ---------------------------------------------------------
-- 4. Role Creation & Grants
-- ---------------------------------------------------------
CREATE ROLE IF NOT EXISTS SOFTWARE_SALES_DEMO_ROLE;

-- --- Database Objects ---
GRANT ALL ON DATABASE SOFTWARE_SALES_DEMO_DB TO ROLE SOFTWARE_SALES_DEMO_ROLE;
GRANT USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE SOFTWARE_SALES_DEMO_ROLE;

-- --- Schema Objects ---
GRANT ALL ON SCHEMA SOFTWARE_SALES_DEMO_DB.PUBLIC TO ROLE SOFTWARE_SALES_DEMO_ROLE;
GRANT USAGE, CREATE AGENT ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE SOFTWARE_SALES_DEMO_ROLE;

-- --- Compute & Warehouse ---
GRANT ALL ON WAREHOUSE SOFTWARE_SALES_DEMO_WH TO ROLE SOFTWARE_SALES_DEMO_ROLE;

-- --- Integrations ---
GRANT USAGE ON INTEGRATION software_sales_demo_external_access_integration TO ROLE SOFTWARE_SALES_DEMO_ROLE;
GRANT USAGE ON INTEGRATION software_sales_demo_slack_mcp_integration TO ROLE SOFTWARE_SALES_DEMO_ROLE;
GRANT USAGE ON INTEGRATION SOFTWARE_SALES_DEMO_GITHUB_API_INTEGRATION TO ROLE SOFTWARE_SALES_DEMO_ROLE;

-- MCP Servers
GRANT USAGE ON MCP SERVER software_sales_demo_slack_mcp_server TO ROLE SOFTWARE_SALES_DEMO_ROLE;

-- --- Cortex & AI Features ---
-- Access to Cortex Functions (Complete, Translate, etc.)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SOFTWARE_SALES_DEMO_ROLE;
-- Access to PyPi Packages
GRANT DATABASE ROLE SNOWFLAKE.PYPI_REPOSITORY_USER TO ROLE SOFTWARE_SALES_DEMO_ROLE;

-- ---------------------------------------------------------
-- Create new User SOFTWARE_SALES_DEMO_USER
-- ---------------------------------------------------------
CREATE USER IF NOT EXISTS SOFTWARE_SALES_DEMO_USER
    PASSWORD             = '<your-password>'
    LOGIN_NAME           = 'SOFTWARE_SALES_DEMO_USER'
    DISPLAY_NAME         = 'Software Sales Demo User'
    EMAIL                = 'demouser@snowflake.com'
    DEFAULT_ROLE         = SOFTWARE_SALES_DEMO_ROLE
    DEFAULT_WAREHOUSE    = SOFTWARE_SALES_DEMO_WH
    MUST_CHANGE_PASSWORD = TRUE;

-- ---------------------------------------------------------
-- Grant the Role
-- ---------------------------------------------------------
-- Explicitly grant the role to the user so they can use it
GRANT ROLE SOFTWARE_SALES_DEMO_ROLE TO USER SOFTWARE_SALES_DEMO_USER;