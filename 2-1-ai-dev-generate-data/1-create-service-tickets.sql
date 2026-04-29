CREATE OR REPLACE SCHEMA SOFTWARE_SALES_DEMO_DB.CUSTOMER_SERVICE;

CREATE OR REPLACE TABLE SOFTWARE_SALES_DEMO_DB.CUSTOMER_SERVICE.SERVICE_TICKETS (
    CUSTOMER_NAME       VARCHAR,
    TICKET_DATE         DATE,
    TICKET_DESCRIPTION  VARCHAR
);

INSERT INTO SOFTWARE_SALES_DEMO_DB.CUSTOMER_SERVICE.SERVICE_TICKETS (CUSTOMER_NAME, TICKET_DATE, TICKET_DESCRIPTION) VALUES
-- Acme Corp (top spender ~50k credits)
('Acme Corp', DATEADD(DAY, -101, CURRENT_DATE()), 'Nightly ELT jobs on the ACME_ETL_WH warehouse are running 2-3x longer than baseline; queries spend significant time in queued state.'),
('Acme Corp', DATEADD(DAY, -79, CURRENT_DATE()), 'COMPUTE credit burn jumped ~40% week-over-week with no announced workload change. Requesting usage review and recommendations.'),
('Acme Corp', DATEADD(DAY, -46, CURRENT_DATE()), 'Need native support for automatic cross-region failover on critical materialized views.'),
('Acme Corp', DATEADD(DAY, -27, CURRENT_DATE()), 'CORTEX_AI inference latency spikes intermittently above 10 seconds during business hours.'),
('Acme Corp', DATEADD(DAY, -7, CURRENT_DATE()), 'Unexpected AUTO_CLUSTERING charges appearing on large fact table; would like guidance on tuning cluster keys.'),
('Acme Corp', DATEADD(DAY, -14, CURRENT_DATE()), 'Unexpected cost spike. Please provide support to investigate the issue.'),

-- Stark Industries (top spender ~50k credits)
('Stark Industries', DATEADD(DAY, -107, CURRENT_DATE()), 'Large Snowpark workloads are hitting memory spill frequently on X-Large warehouse.'),
('Stark Industries', DATEADD(DAY, -83, CURRENT_DATE()), 'Request GPU-backed warehouses for in-database deep learning inference.'),
('Stark Industries', DATEADD(DAY, -59, CURRENT_DATE()), 'SERVERLESS_TASKS credits increased sharply; would like per-task credit attribution in the UI.'),
('Stark Industries', DATEADD(DAY, -19, CURRENT_DATE()), 'Query compilation times on wide tables (>500 columns) have regressed noticeably.'),

-- Virtucon (~37k)
('Virtucon', DATEADD(DAY, -97, CURRENT_DATE()), 'Cloud services billing exceeded the 10% threshold for three consecutive days. Need help identifying offending queries.'),
('Virtucon', DATEADD(DAY, -70, CURRENT_DATE()), 'SNOWPIPE ingestion lag grew from seconds to several minutes on high-volume streams.'),
('Virtucon', DATEADD(DAY, -35, CURRENT_DATE()), 'Would like native row-level lineage export to our external data catalog.'),
('Virtucon', DATEADD(DAY, -14, CURRENT_DATE()), 'MATERIALIZED_VIEW maintenance credits appear high relative to query benefit; requesting analysis.'),

-- Globex Industries (~37k)
('Globex Industries', DATEADD(DAY, -89, CURRENT_DATE()), 'Dashboard queries on BI warehouse consistently queue during 9am-10am EST peak.'),
('Globex Industries', DATEADD(DAY, -66, CURRENT_DATE()), 'Need scheduled auto-resize for warehouses based on historical load patterns.'),
('Globex Industries', DATEADD(DAY, -42, CURRENT_DATE()), 'CORTEX_AI credits tripled this month after enabling AI_CLASSIFY; requesting cost controls.'),
('Globex Industries', DATEADD(DAY, -9, CURRENT_DATE()), 'Result cache hit rate dropped significantly after recent table clustering change.'),

-- Tyrell Corporation (~37k)
('Tyrell Corporation', DATEADD(DAY, -111, CURRENT_DATE()), 'Request ability to pin specific query plans to avoid regression after optimizer updates.'),
('Tyrell Corporation', DATEADD(DAY, -74, CURRENT_DATE()), 'Data sharing consumers report slow query performance on shared secure views.'),
('Tyrell Corporation', DATEADD(DAY, -33, CURRENT_DATE()), 'Compute credits on TYRELL_REPORTING_WH doubled without corresponding workload increase.'),

-- Hooli (~36k)
('Hooli', DATEADD(DAY, -104, CURRENT_DATE()), 'Total monthly credit consumption trending 25% above forecast; need recommendations to right-size warehouses.'),
('Hooli', DATEADD(DAY, -77, CURRENT_DATE()), 'Concurrent query throughput dropped on MEDIUM warehouse after adding workload isolation.'),
('Hooli', DATEADD(DAY, -51, CURRENT_DATE()), 'Native connector for streaming Protobuf events directly into Snowflake tables.'),
('Hooli', DATEADD(DAY, -25, CURRENT_DATE()), 'Serverless compute for tasks running every minute is costly; would like configurable minimum billing granularity.'),
('Hooli', DATEADD(DAY, -4, CURRENT_DATE()), 'Time Travel queries on 30-day retention tables are significantly slower than point-in-time queries.'),

-- Umbrella Co (~36k)
('Umbrella Co', DATEADD(DAY, -99, CURRENT_DATE()), 'External table queries against S3 parquet data are 5x slower than native tables for similar volume.'),
('Umbrella Co', DATEADD(DAY, -60, CURRENT_DATE()), 'Need fine-grained tag-based masking policies applied at query runtime per role.'),
('Umbrella Co', DATEADD(DAY, -38, CURRENT_DATE()), 'Auto-clustering credits exceeding storage savings; need recommendations for when to disable.'),

-- Gringotts Bank (~36k)
('Gringotts Bank', DATEADD(DAY, -93, CURRENT_DATE()), 'Require customer-managed keys (CMK) rotation automation with HSM integration.'),
('Gringotts Bank', DATEADD(DAY, -72, CURRENT_DATE()), 'Regulatory reporting queries on partitioned transaction history table have degraded since Q4.'),
('Gringotts Bank', DATEADD(DAY, -30, CURRENT_DATE()), 'Cloud services layer consuming ~12% of compute; need deeper visibility into metadata operations.'),
('Gringotts Bank', DATEADD(DAY, -11, CURRENT_DATE()), 'Cross-region replication lag for BUSINESS_CRITICAL account occasionally exceeds RPO target.'),

-- Initech (~28k)
('Initech', DATEADD(DAY, -108, CURRENT_DATE()), 'Monthly spend exceeded contracted allotment; request breakdown by warehouse and service type.'),
('Initech', DATEADD(DAY, -68, CURRENT_DATE()), 'Small warehouse repeatedly suspending and resuming, adding latency to interactive queries.'),
('Initech', DATEADD(DAY, -43, CURRENT_DATE()), 'Built-in UI for approving/denying data share requests without leaving Snowsight.'),

-- Cyberdyne Systems (~28k)
('Cyberdyne Systems', DATEADD(DAY, -91, CURRENT_DATE()), 'ML model inference via Snowpark Container Services showing cold-start delays above SLA.'),
('Cyberdyne Systems', DATEADD(DAY, -64, CURRENT_DATE()), 'Request native vector index on VARIANT columns for embedding search workflows.'),
('Cyberdyne Systems', DATEADD(DAY, -49, CURRENT_DATE()), 'SPCS compute pool credits grew 3x after scaling GPU nodes; need autoscaling policy options.'),
('Cyberdyne Systems', DATEADD(DAY, -21, CURRENT_DATE()), 'AI_COMPLETE calls intermittently timeout during batch scoring jobs.'),

-- Oscorp (~28k)
('Oscorp', DATEADD(DAY, -103, CURRENT_DATE()), 'Storage credits rising unexpectedly; suspect Time Travel and Fail-safe retention on dropped tables.'),
('Oscorp', DATEADD(DAY, -81, CURRENT_DATE()), 'Clustering depth on OSCORP_LAB_RESULTS fact table trending upward; reclustering not keeping up.'),
('Oscorp', DATEADD(DAY, -39, CURRENT_DATE()), 'Support for hierarchical/recursive row access policies without CTE workarounds.'),
('Oscorp', DATEADD(DAY, -17, CURRENT_DATE()), 'Secure UDF invocations incurring high compilation overhead in repeated calls.'),

-- Massive Dynamic (~28k)
('Massive Dynamic', DATEADD(DAY, -114, CURRENT_DATE()), 'Would like official support for Iceberg tables with automatic schema evolution.'),
('Massive Dynamic', DATEADD(DAY, -75, CURRENT_DATE()), 'Warehouse auto-scale-out kicked in unexpectedly on steady workload, doubling compute charges.'),
('Massive Dynamic', DATEADD(DAY, -55, CURRENT_DATE()), 'JOIN on two billion-row tables spills to local storage on LARGE warehouse.'),

-- LexCorp (~27k)
('LexCorp', DATEADD(DAY, -100, CURRENT_DATE()), 'Snowpipe Streaming client reporting elevated commit latency on high-throughput topic.'),
('LexCorp', DATEADD(DAY, -62, CURRENT_DATE()), 'CORTEX_AI spend on AI_COMPLETE exceeded budget; need per-function spending limits.'),
('LexCorp', DATEADD(DAY, -47, CURRENT_DATE()), 'Request in-product alerting when resource monitor thresholds are breached, via email and webhook.'),
('LexCorp', DATEADD(DAY, -23, CURRENT_DATE()), 'Dynamic Table refresh lag occasionally exceeds configured TARGET_LAG on chained pipelines.'),

-- Wayne Enterprises (~27k)
('Wayne Enterprises', DATEADD(DAY, -96, CURRENT_DATE()), 'Finance team requests chargeback reporting by cost center tag; current query history view is insufficient.'),
('Wayne Enterprises', DATEADD(DAY, -71, CURRENT_DATE()), 'Search optimization service not improving point-lookup queries on wide dimension table.'),
('Wayne Enterprises', DATEADD(DAY, -34, CURRENT_DATE()), 'Support for geo-partitioning data residency at the schema level for compliance.'),

-- Pied Piper (~22k)
('Pied Piper', DATEADD(DAY, -105, CURRENT_DATE()), 'Need a CLI command to diff semantic views across environments.'),
('Pied Piper', DATEADD(DAY, -85, CURRENT_DATE()), 'Streamlit app backed by Snowflake is slow to render; queries appear to recompile each session.'),
('Pied Piper', DATEADD(DAY, -41, CURRENT_DATE()), 'Free credit exhaustion earlier than anticipated on dev account; request spend projection tools.'),
('Pied Piper', DATEADD(DAY, -8, CURRENT_DATE()), 'Cortex Analyst queries on new semantic view returning in 15+ seconds for simple aggregations.'),

-- Dunder Mifflin (~22k)
('Dunder Mifflin', DATEADD(DAY, -112, CURRENT_DATE()), 'Compute credits for ad-hoc XS warehouse higher than expected due to frequent auto-resume events.'),
('Dunder Mifflin', DATEADD(DAY, -65, CURRENT_DATE()), 'COPY INTO from external stage slows during business hours, suspect cross-region egress.'),
('Dunder Mifflin', DATEADD(DAY, -32, CURRENT_DATE()), 'Request Excel-style pivot export directly from Snowsight query results.'),

-- Soylent Corp (~23k)
('Soylent Corp', DATEADD(DAY, -98, CURRENT_DATE()), 'Materialized view on daily aggregate table not being selected by optimizer for matching queries.'),
('Soylent Corp', DATEADD(DAY, -78, CURRENT_DATE()), 'Native support for UPSERT with DELETE-when-not-matched-by-source semantics.'),
('Soylent Corp', DATEADD(DAY, -44, CURRENT_DATE()), 'Warehouse idle suspension set to 60 seconds, but billing showing charges for longer idle periods.'),
('Soylent Corp', DATEADD(DAY, -15, CURRENT_DATE()), 'Task graph executions intermittently delayed by up to 2 minutes past schedule.'),

-- Wonka Industries (~23k)
('Wonka Industries', DATEADD(DAY, -110, CURRENT_DATE()), 'Request official Python connector support for async query execution with backpressure.'),
('Wonka Industries', DATEADD(DAY, -61, CURRENT_DATE()), 'Query attribution shows high credit usage by service account; need ability to enforce warehouse size caps per role.'),
('Wonka Industries', DATEADD(DAY, -37, CURRENT_DATE()), 'Stored procedure using JavaScript UDF runs 3x slower than equivalent SQL procedure.'),
('Wonka Industries', DATEADD(DAY, -12, CURRENT_DATE()), 'Ability to preview masking policy effects in query profile before deployment.'),
('Wonka Industries', DATEADD(DAY, -2, CURRENT_DATE()), 'INSERT performance degrades during concurrent MERGE operations on same target table.');
