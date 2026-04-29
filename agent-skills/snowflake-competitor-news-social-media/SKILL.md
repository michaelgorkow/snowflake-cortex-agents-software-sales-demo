---
name: snowflake-competitor-news-social-media
description: "Competitive intelligence for Snowflake sales teams: latest news, market updates, and social media sentiment for Snowflake, Databricks, Amazon Redshift, Microsoft Fabric, and Google BigQuery. Triggers: competitor news, market news, social sentiment, trending posts, competitive positioning, what's new with competitors, Databricks news, Redshift news, Fabric news, BigQuery news, social media buzz, Reddit Snowflake, X Snowflake."
---

# Instructions

## Routing Logic
Determine user intent and execute the appropriate workflow:

- **News only** (user asks about news, headlines, announcements, product launches, market updates) → Execute [read_news.md](references/read_news.md)
- **Social media only** (user asks about social buzz, Reddit, X/Twitter, LinkedIn, sentiment, trending posts) → Execute [read_social_media_snow.md](references/read_social_media.md)
- **Both or ambiguous** (user asks for "competitive intelligence", "what's happening with competitors", or a general briefing) → Execute both files and present results as two distinct sections:
  1. **Competitive News Intelligence** (from read_news.md)
  2. **Social Media Buzz** (from read_social_media_snow.md)

When executing both, run the web searches from both files in parallel to minimize latency.
