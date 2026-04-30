-- ---------------------------------------------------------
-- Agent Skill Repository
-- ---------------------------------------------------------
-- This script creates a Git repository object in Snowflake
-- that points to the demo's GitHub repository. It uses the
-- previously created GitHub API integration to provide the
-- Cortex Agent access to custom agent "skills" (prompts, tools,
-- and configurations) stored in the repo, so they can be
-- referenced and loaded directly from Snowflake.
-- ---------------------------------------------------------

USE SCHEMA SOFTWARE_SALES_DEMO_DB.PUBLIC;

CREATE OR REPLACE GIT REPOSITORY agent_skills
  API_INTEGRATION = SOFTWARE_SALES_DEMO_GITHUB_API_INTEGRATION
  ORIGIN = 'https://github.com/michaelgorkow/snowflake-cortex-agents-software-sales-demo';