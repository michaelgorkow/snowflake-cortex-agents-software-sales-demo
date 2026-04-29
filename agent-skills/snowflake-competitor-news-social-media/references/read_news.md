## Instructions
Follow these instructions to retrieve and present the latest news for Snowflake and its competitors.

## Date Handling
- `{date}` = today's date in `YYYY-MM-DD` format.
- `{month_year}` = current month and year (e.g., `April 2026`).
- The search window covers the **current month**.

## Steps

1. **Discover** — `web_search` in parallel. **Use these exact search queries verbatim** (only replacing placeholders with actual values):
   - Snowflake: `Snowflake data cloud news {month_year}`
   - Databricks: `Databricks news {month_year}`
   - Amazon Redshift: `Amazon Redshift news {month_year}`
   - Microsoft Fabric: `Microsoft Fabric news {month_year}`
   - Google BigQuery: `Google BigQuery news {month_year}`
2. **Parse** — Extract headlines, source names, and links. Only include results from the current month. Deduplicate across sources.
3. **Output** — Present results using the [output template](#output-template).

## Output Template
```
## Competitive News Intelligence
**Period: {month_year}**

### Snowflake News
- [Headline](link) — [Source]

### Competitor News

**Databricks:**
- [Headline](link) — [Source]

**Amazon Redshift:**
- [Headline](link) — [Source]

**Microsoft Fabric:**
- [Headline](link) — [Source]

**Google BigQuery:**
- [Headline](link) — [Source]

### Key Insights
[1-2 sentence summary of competitive positioning and notable shifts]

### Sales Takeaways
- [Actionable recommendation for sales teams based on the news, e.g., counter-positioning points, upcoming threats, or opportunities to highlight Snowflake advantages]
- [If a competitor announced a major feature, suggest how to address it in customer conversations]
```
