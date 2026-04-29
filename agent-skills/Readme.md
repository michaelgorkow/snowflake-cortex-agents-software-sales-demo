# Cortex Agent Skills

A collection of reusable **skills** for [Snowflake Cortex Agents](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents) that extend agent capabilities with domain-specific workflows, tools, and instructions.

Each skill in this repository is a self-contained module with its own `SKILL.md`, supporting assets, and documentation — designed to be dropped into a Cortex Agent configuration and invoked when a user's intent matches the skill's domain.

## Repository Structure

```
agent-skills/
├── snowflake-competitor-news-social-media/   # Real-time competitive intelligence
└── snowflake-customer-consumption-forecast/  # Prophet-based credit consumption forecasts
```

## Available Skills

| Skill | Description |
|-------|-------------|
| [**Competitor News & Social Media**](./snowflake-competitor-news-social-media) | Delivers current-month news headlines and social buzz (X, Reddit, LinkedIn) for Snowflake and its key competitors — Databricks, Amazon Redshift, Microsoft Fabric, and Google BigQuery — with sales takeaways. |
| [**Customer Consumption Forecast**](./snowflake-customer-consumption-forecast) | Fits a Prophet time-series model on a customer's daily credit history and produces both an interactive Plotly HTML report and a static PDF, delivered as downloadable assets. |

## Anatomy of a Skill

Every skill follows a common structure:

- **`SKILL.md`** — Core skill definition: trigger conditions, workflow, tool invocations, and output format. This is the file the Cortex Agent loads.
- **`Readme.md`** — Human-facing documentation with example inputs, outputs, and usage triggers.
- **Supporting assets** (optional) — Python templates, reference data, additional workflow files (e.g., `forecast.py`, `references/`, `requirements.txt`).

## Getting Started

1. Browse the skills above and pick one that fits your use case.
2. Read the skill's `Readme.md` for a quick overview and example triggers.
3. Review the `SKILL.md` to understand required tools, data sources, and workflow steps.
4. Register the skill with your Cortex Agent following the [Cortex Agents documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents).
