-- ---------------------------------------------------------
-- Semantic View - Customer Consumption
-- ---------------------------------------------------------
-- This script creates the CUSTOMER_CONSUMPTION semantic view,
-- which exposes a business-friendly model over the
-- CUSTOMER_ACCOUNTS and DAILY_CREDIT_CONSUMPTION tables.
-- It defines tables, relationships, facts (CREDITS_USED), and
-- dimensions (account, customer, region, cloud provider, edition,
-- service type, warehouse, usage date), and wires the
-- CUSTOMER_NAME dimension to the CUSTOMER_SEARCH_NAME Cortex
-- Search Service for fuzzy name resolution.
--
-- This semantic view is used by Cortex Analyst in the demo to
-- translate natural-language questions into accurate SQL over
-- customer consumption data.
-- ---------------------------------------------------------

create or replace semantic view SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_CONSUMPTION
	tables (
		SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_ACCOUNTS primary key (ACCOUNT_ID) comment='The table contains records of customer accounts associated with software subscriptions. Each record represents a single account and includes details about the customer, their geographic region, cloud provider, software edition, and contract start date.',
		SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.DAILY_CREDIT_CONSUMPTION primary key (USAGE_ID) comment='The table contains records of daily credit consumption across customer accounts. Each record captures usage at the level of service type and virtual warehouse, covering a rolling 365-day window.'
	)
	relationships (
		DAILY_CREDIT_CONSUMPTION_TO_CUSTOMER_ACCOUNTS as DAILY_CREDIT_CONSUMPTION(ACCOUNT_ID) references CUSTOMER_ACCOUNTS(ACCOUNT_ID)
	)
	facts (
		DAILY_CREDIT_CONSUMPTION.CREDITS_USED as CREDITS_USED comment='Total Snowflake credits consumed for this account/service/warehouse on USAGE_DATE.'
	)
	dimensions (
		CUSTOMER_ACCOUNTS.ACCOUNT_ID as ACCOUNT_ID comment='Unique Snowflake account identifier (surrogate key). Primary key of this dimension.',
		CUSTOMER_ACCOUNTS.ACCOUNT_NAME as ACCOUNT_NAME comment='Human-readable Snowflake account/locator name (e.g. ACME_PROD).',
		CUSTOMER_ACCOUNTS.CLOUD_PROVIDER as CLOUD_PROVIDER comment='Underlying cloud platform hosting the account: AWS, AZURE, or GCP.',
		CUSTOMER_ACCOUNTS.CUSTOMER_NAME as CUSTOMER_NAME comment='Legal name of the customer organization that owns the account.' with cortex search service SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_SEARCH_NAME,
		CUSTOMER_ACCOUNTS.EDITION as EDITION comment='Snowflake edition of the account: STANDARD, ENTERPRISE, or BUSINESS_CRITICAL. Drives per-credit pricing tier.',
		CUSTOMER_ACCOUNTS.REGION as REGION comment='Cloud region where the Snowflake account is deployed (e.g. us-east-1, eu-west-1).',
		CUSTOMER_ACCOUNTS.CONTRACT_START_DATE as CONTRACT_START_DATE comment='Date the customer contract for this account became active. Consumption before this date is not reported.',
		DAILY_CREDIT_CONSUMPTION.ACCOUNT_ID as ACCOUNT_ID comment='Foreign key to CUSTOMER_ACCOUNTS.ACCOUNT_ID identifying the Snowflake account that consumed the credits.',
		DAILY_CREDIT_CONSUMPTION.SERVICE_TYPE as SERVICE_TYPE comment='Billable Snowflake service category: COMPUTE, CLOUD_SERVICES, SERVERLESS_TASKS, AUTO_CLUSTERING, MATERIALIZED_VIEW, SNOWPIPE, CORTEX_AI.',
		DAILY_CREDIT_CONSUMPTION.USAGE_ID as USAGE_ID comment='Surrogate primary key for each daily usage record.',
		DAILY_CREDIT_CONSUMPTION.WAREHOUSE_NAME as WAREHOUSE_NAME comment='Virtual warehouse responsible for the credit usage. Populated only for SERVICE_TYPE = COMPUTE; NULL otherwise.',
		DAILY_CREDIT_CONSUMPTION.USAGE_DATE as USAGE_DATE comment='Calendar date (UTC) that the credits were consumed.'
	)
	comment='Tracks daily Snowflake credit consumption by customer account, service type, and warehouse. Enables analysis of usage trends, cost allocation across cloud providers/regions/editions, and customer-level billing insights over a rolling 365-day window.'
	with extension (CA='{"tables":[{"name":"CUSTOMER_ACCOUNTS","dimensions":[{"name":"ACCOUNT_ID","sample_values":["ACC00003","ACC00002","ACC00001"]},{"name":"ACCOUNT_NAME","sample_values":["ACME_DEV","GLOBEX_ANALYTICS","ACME_PROD"]},{"name":"CLOUD_PROVIDER","sample_values":["AWS","GCP","AZURE"]},{"name":"CUSTOMER_NAME"},{"name":"EDITION","sample_values":["BUSINESS_CRITICAL","ENTERPRISE","STANDARD"]},{"name":"REGION","sample_values":["us-east-1","us-west-2","eu-west-1"]}],"time_dimensions":[{"name":"CONTRACT_START_DATE","sample_values":["2024-03-15","2025-02-20","2023-09-01"]}]},{"name":"DAILY_CREDIT_CONSUMPTION","dimensions":[{"name":"ACCOUNT_ID","sample_values":["ACC00001","ACC00003","ACC00005"]},{"name":"SERVICE_TYPE","sample_values":["COMPUTE","MATERIALIZED_VIEW","AUTO_CLUSTERING"]},{"name":"USAGE_ID","sample_values":["3971","4011","3934"]},{"name":"WAREHOUSE_NAME","sample_values":["ETL_WH","ML_WH","ADHOC_WH"]}],"facts":[{"name":"CREDITS_USED","sample_values":["7.1114","57.9568","8.8645"]}],"time_dimensions":[{"name":"USAGE_DATE","sample_values":["2025-05-10","2025-05-18","2025-05-07"]}],"foreign_keys":[{"fkey_columns":["ACCOUNT_ID"],"pkey_table":{"database":"SOFTWARE_SALES_DEMO_DB","schema":"CUSTOMER_CONSUMPTION_DATA","table":"CUSTOMER_ACCOUNTS"},"pkey_columns":["ACCOUNT_ID"]}]}],"relationships":[{"name":"DAILY_CREDIT_CONSUMPTION_TO_CUSTOMER_ACCOUNTS","relationship_type":"many_to_one","join_type":"inner"}]}');