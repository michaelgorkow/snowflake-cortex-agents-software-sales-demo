USE SCHEMA SOFTWARE_SALES_DEMO_DB.PUBLIC;

CREATE OR REPLACE GIT REPOSITORY agent_skills
  API_INTEGRATION = SOFTWARE_SALES_DEMO_GITHUB_API_INTEGRATION
  ORIGIN = 'https://github.com/michaelgorkow/snowflake-cortex-agents-software-sales-demo';