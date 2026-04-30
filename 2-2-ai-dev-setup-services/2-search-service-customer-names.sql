-- ---------------------------------------------------------
-- Cortex Search Service - Customer Names
-- ---------------------------------------------------------
-- This script creates a Cortex Search Service over the distinct
-- CUSTOMER_NAME values in the CUSTOMER_ACCOUNTS table. It enables
-- fuzzy/semantic lookup of customer names (e.g., resolving
-- variations, typos, or partial matches) so the demo's Cortex
-- Agent and Cortex Analyst can reliably map user-provided names
-- to the canonical customer entries used in structured queries.
-- ---------------------------------------------------------

CREATE OR REPLACE CORTEX SEARCH SERVICE SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_SEARCH_NAME
  ON CUSTOMER_NAME
  WAREHOUSE = SOFTWARE_SALES_DEMO_WH
  TARGET_LAG = '1 hour'
  EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
AS (
  SELECT
      DISTINCT CUSTOMER_NAME
  FROM SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_ACCOUNTS
);