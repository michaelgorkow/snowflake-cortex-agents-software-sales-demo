---
name: snowflake-customer-consumption-forecast
description: "Generate a daily Snowflake credit consumption forecast for a specific customer. Queries historical daily credit usage from Snowflake, fits a Prophet time-series model in Python, and produces both an interactive Plotly HTML report (plotly.js from CDN) and a downloadable static PDF. Triggers: consumption forecast, credit forecast, forecast credits, predict consumption, customer consumption forecast, daily credit forecast, prophet forecast, usage forecast, interactive forecast, plotly forecast, forecast PDF, download forecast."
---

# Snowflake Customer Consumption Forecast

## Purpose
Produce a **daily credit consumption forecast** for a given customer using historical usage stored in Snowflake and the `prophet` library. The forecast is rendered **twice** from a single Plotly figure:
1. An **interactive HTML report** that loads `plotly.js` from `https://cdn.plot.ly/plotly-3.5.0.min.js`.
2. A **static PDF** (via Plotly + Kaleido) suitable for download, email, or Salesforce attachment.

## Prerequisites
- Python packages are declared in [requirements.txt](requirements.txt). Before running the forecast, install them with:
  ```bash
  pip install -r requirements.txt
  ```
  Install step is **mandatory** on first run or whenever dependencies are missing.
- Access to the following Snowflake tables:
  - `SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.DAILY_CREDIT_CONSUMPTION` (columns: `account_id`, `usage_date`, `credits_used`)
  - `SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_ACCOUNTS` (columns: `account_id`, `customer_name`)
- An active Snowflake connection available to Snowpark `Session.builder.getOrCreate()`.

## Instructions
When a user asks for a customer credit consumption forecast:

1. **Install dependencies.** Run `pip install -r requirements.txt` from the skill directory to ensure `snowflake-snowpark-python[pandas]`, `numpy`, `prophet`, and `matplotlib` are available.
2. **Resolve the customer name.** Use the `customer-lookup` tool to convert the user's free-text customer reference into the exact `customer_name` as stored in `CUSTOMER_ACCOUNTS`. Do NOT guess the name.
3. **Choose forecast parameters.** Unless the user specifies otherwise, use these defaults:
   - Historical window: last 120 days up to today
   - Forecast horizon: 30 days
   - Output HTML path: `/tmp/<customer_slug>_forecast.html`
   - Output PDF path:  `/tmp/<customer_slug>_forecast.pdf`
4. **Run the forecast script.** Use [forecast.py](forecast.py) as the template. Substitute:
   - `{{CUSTOMER_NAME}}` — exact customer name from step 2
   - `{{START_DATE}}` / `{{END_DATE}}` — historical window (YYYY-MM-DD)
   - `{{FORECAST_DAYS}}` — forecast horizon (integer, default 30)
   - `{{OUTPUT_HTML}}` — absolute path for the interactive HTML output
   - `{{OUTPUT_PDF}}` — absolute path for the static PDF output
5. **Report back to the user:**
   - Historical summary (rows loaded, mean/std daily credits)
   - Forecast summary (total predicted credits over horizon, daily mean)
   - Flag any data quality issues (missing days, zero-consumption days, large gaps)
6. **Provide downloadable results to the user.** Call the `upload_asset` tool **twice**, once per artifact, and embed the returned links in the final reply:
   - Upload the **interactive HTML** from `{{OUTPUT_HTML}}` (MIME: `text/html`). Label it “Interactive forecast (HTML)”.
   - Upload the **static PDF** from `{{OUTPUT_PDF}}` (MIME: `application/pdf`). Label it “Forecast report (PDF)”.
   - Present both download links clearly; do NOT reference local `/tmp` paths in the user-facing answer.

## Output Contract
Two artifacts are produced from the same underlying Plotly figure, so the HTML and PDF render identical data. Both MUST be delivered to the user via the `upload_asset` tool:
- **Interactive HTML** (uploaded from `{{OUTPUT_HTML}}`) — historical actuals (points), in-sample fit, forecast line, 80% uncertainty band, `today` cutoff marker. Loads `plotly.js` from `https://cdn.plot.ly/plotly-3.5.0.min.js` (internet required when opening).
- **Static PDF** (uploaded from `{{OUTPUT_PDF}}`) — self-contained, suitable for download / email / Salesforce attachment. Rendered by Plotly using the `kaleido` backend (1200x675 @ 2x scale).
- A short textual summary suitable for pasting into a Salesforce note or email, including both `upload_asset` download links.

## Failure Modes
- If fewer than 14 historical days are available, do NOT fit Prophet. Return a message explaining insufficient data.
- If the customer name cannot be resolved, ask the user to clarify.
