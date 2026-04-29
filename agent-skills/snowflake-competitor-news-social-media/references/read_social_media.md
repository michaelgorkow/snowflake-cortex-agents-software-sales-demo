## Instructions
Follow these instructions to retrieve and present the latest social media content about Snowflake and its competitors.

## Date Handling
- `{date}` = today's date in `YYYY-MM-DD` format.
- `{month_year}` = current month and year (e.g., `April 2026`).
- The search window covers the **current month**.

## Steps

1. **Discover** — `web_search` in parallel. **Use these exact search queries verbatim** (only replacing placeholders with actual values):
   - **Snowflake:**
     - X: `Snowflake SNOW x.com {month_year}`
     - Reddit: `Snowflake data cloud reddit {month_year}`
     - LinkedIn: `Snowflake Inc linkedin {month_year}`
   - **Databricks:**
     - X: `Databricks x.com {month_year}`
     - Reddit: `Databricks reddit {month_year}`
     - LinkedIn: `Databricks linkedin {month_year}`
   - **Amazon Redshift:**
     - X: `Amazon Redshift x.com {month_year}`
     - Reddit: `Amazon Redshift reddit {month_year}`
     - LinkedIn: `Amazon Redshift linkedin {month_year}`
   - **Microsoft Fabric:**
     - X: `Microsoft Fabric x.com {month_year}`
     - Reddit: `Microsoft Fabric reddit {month_year}`
     - LinkedIn: `Microsoft Fabric linkedin {month_year}`
   - **Google BigQuery:**
     - X: `Google BigQuery x.com {month_year}`
     - Reddit: `Google BigQuery reddit {month_year}`
     - LinkedIn: `Google BigQuery linkedin {month_year}`

2. **Filter** — From the results, select the top 3 most relevant posts per platform per company. Only include results from the current month. Discard low-quality or off-topic results.

3. **Output** — Present results using the [output template](#output-template).

## Output Template
```
## Social Media Buzz
**Period: {month_year}**

### Trending on X
**Snowflake:**
- [Post summary or quote](link) — @handle
- [Post summary or quote](link) — @handle

**Databricks:**
- [Post summary or quote](link) — @handle

**Redshift / Fabric / BigQuery:**
- [Post summary or quote](link) — @handle

### Reddit Discussions
**Snowflake:**
- [Thread title](link) — r/subreddit
- [Thread title](link) — r/subreddit

**Databricks:**
- [Thread title](link) — r/subreddit

**Competitors:**
- [Thread title](link) — r/subreddit — [Company]

### LinkedIn Highlights
**Snowflake:**
- [Post summary](link) — [Author/Company]

**Databricks:**
- [Post summary](link) — [Author/Company]

**Competitors:**
- [Post summary](link) — [Author/Company] — [Competitor]

### Sentiment Summary
[1-2 sentences on overall community sentiment toward Snowflake vs. competitors this week]

### Sales Takeaways
- [Actionable insight for sales teams, e.g., common customer complaints to address, praise to amplify, or competitor criticism to leverage]
- [If a competitor is trending negatively, suggest how to position Snowflake in those conversations]
```
