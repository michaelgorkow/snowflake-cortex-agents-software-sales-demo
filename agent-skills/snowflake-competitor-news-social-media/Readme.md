# Snowflake Competitor News & Social Media Skill

A Cortex Agent skill that delivers real-time competitive intelligence for Snowflake sales teams — covering the latest news headlines and social media sentiment for Snowflake and its key competitors: **Databricks**, **Amazon Redshift**, **Microsoft Fabric**, and **Google BigQuery**.

## How It Works

The skill routes to one or both of two workflows depending on user intent:

| Intent | Workflow |
|--------|----------|
| News, headlines, announcements, product launches | `read_news.md` — parallel web searches for current-month news per vendor |
| Social buzz, Reddit, X/Twitter, LinkedIn, sentiment | `read_social_media.md` — parallel searches across X, Reddit, and LinkedIn per vendor |
| General competitive briefing or ambiguous request | Both workflows run in parallel and results are presented in two sections |

Searches are scoped to the **current month** and results are filtered to the top 3 most relevant items per platform per company.

## Output

### Competitive News Intelligence
- Headline list per vendor (Snowflake + 4 competitors)
- Key Insights summary (1–2 sentences on competitive positioning)
- Sales Takeaways (counter-positioning points, upcoming threats, opportunities)

### Social Media Buzz
- Trending posts on X per vendor
- Reddit discussion threads per vendor
- LinkedIn highlights per vendor
- Sentiment summary (overall community tone toward Snowflake vs. competitors)
- Sales Takeaways (customer complaints to address, competitor criticism to leverage)

## Example Triggers

- *"What's the latest competitor news?"*
- *"What are people saying about Databricks on Reddit this month?"*
- *"Give me a competitive intelligence briefing."*
- *"What's trending on X about Microsoft Fabric?"*
- *"Any new BigQuery announcements?"*
