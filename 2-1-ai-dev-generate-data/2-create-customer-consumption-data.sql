-- ---------------------------------------------------------
-- Create Customer Consumption Data
-- ---------------------------------------------------------
-- This script creates the CUSTOMER_CONSUMPTION_DATA schema
-- in the SOFTWARE_SALES_DEMO_DB database and populates it with:
--   * CUSTOMER_ACCOUNTS        - a dimension table of Snowflake
--                                customer accounts (edition, region,
--                                cloud provider, contract start).
--   * DAILY_CREDIT_CONSUMPTION - a daily-grain fact table of
--                                synthetic credit consumption per
--                                account, service type and (for
--                                COMPUTE) warehouse, covering the
--                                trailing 365 days.
--
-- The generated data is structured numeric/dimensional data used
-- by downstream demo assets (semantic views, Cortex Analyst)
-- to analyze customer usage and spending trends.
-- ---------------------------------------------------------

CREATE OR REPLACE SCHEMA SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA;

-- Customer accounts dimension
CREATE OR REPLACE TABLE SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_ACCOUNTS (
    ACCOUNT_ID      STRING       NOT NULL
        COMMENT 'Unique Snowflake account identifier (surrogate key). Primary key of this dimension.',
    ACCOUNT_NAME    STRING
        COMMENT 'Human-readable Snowflake account/locator name (e.g. ACME_PROD).',
    CUSTOMER_NAME   STRING
        COMMENT 'Legal name of the customer organization that owns the account.',
    REGION          STRING
        COMMENT 'Cloud region where the Snowflake account is deployed (e.g. us-east-1, eu-west-1).',
    CLOUD_PROVIDER  STRING
        COMMENT 'Underlying cloud platform hosting the account: AWS, AZURE, or GCP.',
    EDITION         STRING
        COMMENT 'Snowflake edition of the account: STANDARD, ENTERPRISE, or BUSINESS_CRITICAL. Drives per-credit pricing tier.',
    CONTRACT_START_DATE DATE
        COMMENT 'Date the customer contract for this account became active. Consumption before this date is not reported.',
    CONSTRAINT PK_CUSTOMER_ACCOUNTS PRIMARY KEY (ACCOUNT_ID)
)
COMMENT = 'Dimension table containing the Snowflake customer accounts billed by Snowflake. One row per account; multiple accounts may roll up to the same customer.';

INSERT INTO SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_ACCOUNTS VALUES
  ('ACC00001','ACME_PROD',      'Acme Corp',             'us-east-1',     'AWS',   'ENTERPRISE',       '2024-03-15'),
  ('ACC00002','ACME_DEV',       'Acme Corp',             'us-east-1',     'AWS',   'ENTERPRISE',       '2024-03-15'),
  ('ACC00003','GLOBEX_ANALYTICS','Globex Industries',    'us-west-2',     'AWS',   'BUSINESS_CRITICAL','2023-09-01'),
  ('ACC00004','INITECH_MAIN',   'Initech',               'eu-west-1',     'AWS',   'ENTERPRISE',       '2025-01-10'),
  ('ACC00005','UMBRELLA_DW',    'Umbrella Co',           'us-central1',   'GCP',   'BUSINESS_CRITICAL','2023-06-22'),
  ('ACC00006','STARK_PROD',     'Stark Industries',      'us-east-2',     'AWS',   'ENTERPRISE',       '2024-11-01'),
  ('ACC00007','STARK_DEV',      'Stark Industries',      'us-east-2',     'AWS',   'STANDARD',         '2024-11-01'),
  ('ACC00008','WAYNE_ANALYTICS','Wayne Enterprises',     'eastus',        'AZURE', 'ENTERPRISE',       '2023-02-14'),
  ('ACC00009','WONKA_PROD',     'Wonka Industries',      'us-west-1',     'AWS',   'STANDARD',         '2025-05-30'),
  ('ACC00010','HOOLI_PROD',     'Hooli',                 'us-west-2',     'AWS',   'BUSINESS_CRITICAL','2022-10-18'),
  ('ACC00011','PIEDPIPER_DW',   'Pied Piper',            'us-west-2',     'AWS',   'STANDARD',         '2025-08-12'),
  ('ACC00012','CYBERDYNE_ML',   'Cyberdyne Systems',     'westus2',       'AZURE', 'ENTERPRISE',       '2024-04-04'),
  ('ACC00013','TYRELL_PROD',    'Tyrell Corporation',    'ap-southeast-1','AWS',   'BUSINESS_CRITICAL','2023-12-01'),
  ('ACC00014','SOYLENT_PROD',   'Soylent Corp',          'us-east-1',     'AWS',   'STANDARD',         '2025-02-20'),
  ('ACC00015','MASSIVEDYN_DW',  'Massive Dynamic',       'europe-west4',  'GCP',   'ENTERPRISE',       '2024-07-07'),
  ('ACC00016','OSCORP_MAIN',    'Oscorp',                'us-east-1',     'AWS',   'ENTERPRISE',       '2023-05-11'),
  ('ACC00017','VIRTUCON_PROD',  'Virtucon',              'eu-central-1',  'AWS',   'BUSINESS_CRITICAL','2024-01-09'),
  ('ACC00018','DUNDER_MAIN',    'Dunder Mifflin',        'us-east-2',     'AWS',   'STANDARD',         '2025-10-15'),
  ('ACC00019','GRINGOTTS_DW',   'Gringotts Bank',        'eu-west-2',     'AWS',   'BUSINESS_CRITICAL','2022-11-30'),
  ('ACC00020','LEXCORP_ANALYTICS','LexCorp',             'northeurope',   'AZURE', 'ENTERPRISE',       '2024-09-18');

-- Daily credit consumption fact table
CREATE OR REPLACE TABLE SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.DAILY_CREDIT_CONSUMPTION (
    USAGE_ID       NUMBER(18,0) NOT NULL AUTOINCREMENT
        COMMENT 'Surrogate primary key for each daily usage record.',
    USAGE_DATE     DATE         NOT NULL
        COMMENT 'Calendar date (UTC) that the credits were consumed.',
    ACCOUNT_ID     STRING       NOT NULL
        COMMENT 'Foreign key to CUSTOMER_ACCOUNTS.ACCOUNT_ID identifying the Snowflake account that consumed the credits.',
    SERVICE_TYPE   STRING       NOT NULL
        COMMENT 'Billable Snowflake service category: COMPUTE, CLOUD_SERVICES, SERVERLESS_TASKS, AUTO_CLUSTERING, MATERIALIZED_VIEW, SNOWPIPE, CORTEX_AI.',
    WAREHOUSE_NAME STRING
        COMMENT 'Virtual warehouse responsible for the credit usage. Populated only for SERVICE_TYPE = COMPUTE; NULL otherwise.',
    CREDITS_USED   NUMBER(18,4)
        COMMENT 'Total Snowflake credits consumed for this account/service/warehouse on USAGE_DATE.',
    CONSTRAINT PK_DAILY_CREDIT_CONSUMPTION PRIMARY KEY (USAGE_ID),
    CONSTRAINT FK_DCC_ACCOUNT FOREIGN KEY (ACCOUNT_ID)
        REFERENCES SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_ACCOUNTS(ACCOUNT_ID)
)
COMMENT = 'Daily grain fact table of Snowflake credit consumption per customer account, service type, and (for COMPUTE) virtual warehouse. Covers the last 365 days through the current date.';

-- Generate daily consumption for each account across service types and warehouses
INSERT INTO SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.DAILY_CREDIT_CONSUMPTION
    (USAGE_DATE, ACCOUNT_ID, SERVICE_TYPE, WAREHOUSE_NAME, CREDITS_USED)
WITH date_spine AS (
    SELECT DATEADD(DAY, SEQ4(), DATEADD(DAY, -364, CURRENT_DATE())) AS USAGE_DATE
    FROM TABLE(GENERATOR(ROWCOUNT => 365))  -- Trailing 365 days through CURRENT_DATE
),
svc AS (
    SELECT * FROM VALUES
        ('COMPUTE',            40.0),
        ('CLOUD_SERVICES',      2.5),
        ('SERVERLESS_TASKS',    6.0),
        ('AUTO_CLUSTERING',     3.0),
        ('MATERIALIZED_VIEW',   1.8),
        ('SNOWPIPE',            4.2),
        ('CORTEX_AI',           5.5)
    AS t(SERVICE_TYPE, BASE_CREDITS)
),
wh AS (
    SELECT * FROM VALUES
        ('ETL_WH'), ('BI_WH'), ('ADHOC_WH'), ('ML_WH')
    AS t(WAREHOUSE_NAME)
)
SELECT
    d.USAGE_DATE,
    a.ACCOUNT_ID,
    s.SERVICE_TYPE,
    CASE WHEN s.SERVICE_TYPE = 'COMPUTE' THEN w.WAREHOUSE_NAME ELSE NULL END AS WAREHOUSE_NAME,
    ROUND(
        GREATEST(0,
            s.BASE_CREDITS
            * CASE a.EDITION
                WHEN 'BUSINESS_CRITICAL' THEN 1.6
                WHEN 'ENTERPRISE'        THEN 1.2
                ELSE 1.0 END
            * CASE WHEN DAYOFWEEKISO(d.USAGE_DATE) IN (6,7) THEN 0.55 ELSE 1.0 END
            * (1 + ((ABS(HASH(a.ACCOUNT_ID, s.SERVICE_TYPE, COALESCE(w.WAREHOUSE_NAME,'X'), d.USAGE_DATE)) % 46) - 20) / 100.0)
            * CASE WHEN (ABS(HASH(a.ACCOUNT_ID, d.USAGE_DATE, s.SERVICE_TYPE)) % 100) < 3 THEN 1.9 ELSE 1.0 END
            * (1 + (DATEDIFF('day', DATEADD(DAY, -364, CURRENT_DATE()), d.USAGE_DATE) / 400.0))
            -- Acme Corp steep decline over the last 14 days (CURRENT_DATE-13 .. CURRENT_DATE)
            * CASE
                WHEN a.CUSTOMER_NAME = 'Acme Corp'
                     AND d.USAGE_DATE BETWEEN DATEADD(DAY, -13, CURRENT_DATE()) AND CURRENT_DATE()
                THEN GREATEST(0.05, 0.9 - (DATEDIFF('day', DATEADD(DAY, -13, CURRENT_DATE()), d.USAGE_DATE) / 13.0) * 0.80)
                ELSE 1.0
              END
        ),
    4) AS CREDITS_USED
FROM date_spine d
CROSS JOIN SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_ACCOUNTS a
CROSS JOIN svc s
LEFT JOIN wh w ON s.SERVICE_TYPE = 'COMPUTE'
WHERE d.USAGE_DATE >= a.CONTRACT_START_DATE;