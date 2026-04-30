-- ---------------------------------------------------------
-- Cortex Search Service - Service Tickets
-- ---------------------------------------------------------
-- This script creates a Cortex Search Service over the
-- SERVICE_TICKETS table in the CUSTOMER_SERVICE schema.
-- It enables semantic/natural-language search across ticket
-- descriptions, with CUSTOMER_NAME and TICKET_DATE exposed as
-- filterable attributes. The service is used by the demo's
-- Cortex Agent to retrieve relevant support tickets when
-- answering user questions about customer issues.
-- ---------------------------------------------------------

CREATE OR REPLACE CORTEX SEARCH SERVICE SOFTWARE_SALES_DEMO_DB.CUSTOMER_SERVICE.SERVICE_TICKET_SEARCH
  ON TICKET_DESCRIPTION
  ATTRIBUTES CUSTOMER_NAME, TICKET_DATE
  WAREHOUSE = SOFTWARE_SALES_DEMO_WH
  TARGET_LAG = '1 hour'
  EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
AS (
  SELECT
      CUSTOMER_NAME,
      TICKET_DATE,
      TICKET_DESCRIPTION
  FROM SOFTWARE_SALES_DEMO_DB.CUSTOMER_SERVICE.SERVICE_TICKETS
);