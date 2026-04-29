# Snowflake Customer Consumption Forecast Skill

A Cortex Agent skill that produces a **daily credit consumption forecast** for any Snowflake customer. It queries historical daily usage from Snowflake, fits a Prophet time-series model in Python, and delivers two downloadable artifacts: an **interactive Plotly HTML report** and a **static PDF**.

## How It Works

The skill orchestrates a four-step workflow driven by [`SKILL.md`](SKILL.md) and the [`forecast.py`](forecast.py) template:

| Step | Action |
|------|--------|
| 1. Install | `pip install -r requirements.txt` (snowflake-snowpark-python, pandas, numpy, prophet, plotly, kaleido) |
| 2. Resolve | Use the `customer-lookup` tool to map the user's free-text customer reference to the exact `customer_name` in `CUSTOMER_ACCOUNTS` |
| 3. Forecast | Fill the `{{PLACEHOLDERS}}` in `forecast.py`, load history from `SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.DAILY_CREDIT_CONSUMPTION`, fit Prophet, and produce a 30-day forecast (default) |
| 4. Deliver | Write both an interactive HTML and a static PDF, then call `upload_asset` on each to return download links |

Defaults (overridable by the user):
- Historical window: last **120 days** up to today
- Forecast horizon: **30 days**
- Confidence interval: **80%**
- Missing calendar days are filled with `0` so Prophet sees a continuous daily series

## Output

### Interactive HTML Report
- Rendered from a Plotly figure; loads `plotly.js` from `https://cdn.plot.ly/plotly-3.5.0.min.js`
- Historical actuals (scatter), in-sample fit, forecast line, 80% uncertainty band, `today` cutoff marker
- Hover tooltips, zoom, pan, legend toggling
- Delivered via `upload_asset` (MIME `text/html`) — label: *Interactive forecast (HTML)*

### Static PDF
- Rendered from the same figure via Plotly + Kaleido (1200×675 @ 2x scale)
- Self-contained, suitable for download, email, or Salesforce attachment
- Delivered via `upload_asset` (MIME `application/pdf`) — label: *Forecast report (PDF)*

### Textual Summary
- Historical rows loaded + date range
- Historical mean and standard deviation (credits/day)
- Predicted total credits over the forecast horizon and predicted daily mean
- Data quality flags (missing days, large gaps, zero-consumption days)
- Both `upload_asset` download links embedded inline

## Example Triggers

- *"Forecast credit consumption for Stark Industries."*
- *"Give me a 60-day consumption forecast for Acme Corp."*
- *"Predict daily credits for Wayne Enterprises over the next month."*
- *"Run a prophet forecast on Initech's usage."*
- *"Download forecast PDF for Umbrella Corporation."*

## Failure Modes

- Fewer than 14 days of history: skill refuses to fit Prophet and explains that more data is required.
- Customer name cannot be resolved: skill asks the user to clarify instead of guessing.
