"""
Snowflake Customer Consumption Forecast
---------------------------------------
Template script for generating a daily credit consumption forecast for a
single customer using Prophet. Replace the {{PLACEHOLDERS}} before running.

Outputs (both produced in one run):
  * Interactive HTML (Plotly.js loaded from https://cdn.plot.ly/plotly-3.5.0.min.js)
  * Static PDF (rendered by Plotly + Kaleido) for download / attachment.

Usage (after substitution):
    python forecast.py

Required packages: see requirements.txt
"""

import os
import re
import sys

import pandas as pd
import numpy as np
import plotly.graph_objects as go

from prophet import Prophet
from snowflake.snowpark import Session


# ──────────────────────────────────────────────
# 0. Parameters (substitute these placeholders)
# ──────────────────────────────────────────────
CUSTOMER_NAME: str = "{{CUSTOMER_NAME}}"
START_DATE: str = "{{START_DATE}}"             # e.g. "2026-01-01"
END_DATE: str = "{{END_DATE}}"                 # e.g. "2026-04-29"
FORECAST_DAYS: int = int("{{FORECAST_DAYS}}")  # e.g. 30
OUTPUT_HTML: str = "{{OUTPUT_HTML}}"           # e.g. "/tmp/acme_corp_forecast.html"
OUTPUT_PDF: str = "{{OUTPUT_PDF}}"             # e.g. "/tmp/acme_corp_forecast.pdf"

MIN_HISTORY_DAYS = 14
CONFIDENCE_INTERVAL = 0.80
PLOTLY_CDN_URL = "https://cdn.plot.ly/plotly-3.5.0.min.js"


def _slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")


# ──────────────────────────────────────────────
# 1. Load historical data from Snowflake
# ──────────────────────────────────────────────
def load_history(session: Session, customer: str, start: str, end: str) -> pd.DataFrame:
    sql = f"""
    WITH dcc AS (
        SELECT account_id, usage_date, credits_used
        FROM SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.DAILY_CREDIT_CONSUMPTION
    ), ca AS (
        SELECT account_id, customer_name
        FROM SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_ACCOUNTS
    )
    SELECT
        dcc.usage_date          AS usage_date,
        SUM(dcc.credits_used)   AS total_credits_used
    FROM dcc
    JOIN ca ON dcc.account_id = ca.account_id
    WHERE ca.customer_name = '{customer.replace("'", "''")}'
      AND dcc.usage_date BETWEEN '{start}' AND '{end}'
    GROUP BY dcc.usage_date
    ORDER BY dcc.usage_date ASC
    """
    df = session.sql(sql).to_pandas()
    if df.empty:
        return df
    df["USAGE_DATE"] = pd.to_datetime(df["USAGE_DATE"])
    df["TOTAL_CREDITS_USED"] = df["TOTAL_CREDITS_USED"].astype(float)
    full_idx = pd.date_range(df["USAGE_DATE"].min(), df["USAGE_DATE"].max(), freq="D")
    df = (
        df.set_index("USAGE_DATE")
        .reindex(full_idx, fill_value=0.0)
        .rename_axis("USAGE_DATE")
        .reset_index()
    )
    return df.sort_values("USAGE_DATE").reset_index(drop=True)


# ──────────────────────────────────────────────
# 2. Fit Prophet and forecast
# ──────────────────────────────────────────────
def fit_and_forecast(history: pd.DataFrame, horizon_days: int) -> tuple[Prophet, pd.DataFrame]:
    prophet_df = history.rename(
        columns={"USAGE_DATE": "ds", "TOTAL_CREDITS_USED": "y"}
    )[["ds", "y"]]

    model = Prophet(
        interval_width=CONFIDENCE_INTERVAL,
        daily_seasonality=False,
        weekly_seasonality=True,
        yearly_seasonality=False,
        changepoint_prior_scale=0.1,
    )
    model.fit(prophet_df)

    future = model.make_future_dataframe(periods=horizon_days, freq="D")
    forecast = model.predict(future)
    for col in ("yhat", "yhat_lower", "yhat_upper"):
        forecast[col] = forecast[col].clip(lower=0)
    return model, forecast


# ──────────────────────────────────────────────
# 3. Build a Plotly figure (shared by HTML + PDF)
# ──────────────────────────────────────────────
def build_figure(
    history: pd.DataFrame,
    forecast: pd.DataFrame,
    customer: str,
    horizon_days: int,
) -> go.Figure:
    cutoff = history["USAGE_DATE"].max()
    fut = forecast[forecast["ds"] > cutoff]
    hist_fit = forecast[forecast["ds"] <= cutoff]

    fig = go.Figure()

    # Confidence band (drawn first so it sits behind the lines)
    fig.add_trace(go.Scatter(
        x=pd.concat([fut["ds"], fut["ds"][::-1]]),
        y=pd.concat([fut["yhat_upper"], fut["yhat_lower"][::-1]]),
        fill="toself",
        fillcolor="rgba(214,39,40,0.18)",
        line=dict(color="rgba(255,255,255,0)"),
        hoverinfo="skip",
        showlegend=True,
        name=f"{int(CONFIDENCE_INTERVAL*100)}% interval",
    ))

    fig.add_trace(go.Scatter(
        x=history["USAGE_DATE"], y=history["TOTAL_CREDITS_USED"],
        mode="markers",
        marker=dict(size=6, color="#1f77b4"),
        name="Historical daily credits",
        hovertemplate="%{x|%Y-%m-%d}<br>%{y:.1f} credits<extra></extra>",
    ))

    fig.add_trace(go.Scatter(
        x=hist_fit["ds"], y=hist_fit["yhat"],
        mode="lines",
        line=dict(color="#1f77b4", width=1.5, dash="dot"),
        opacity=0.6,
        name="Model fit",
        hovertemplate="%{x|%Y-%m-%d}<br>fit %{y:.1f}<extra></extra>",
    ))

    fig.add_trace(go.Scatter(
        x=fut["ds"], y=fut["yhat"],
        mode="lines",
        line=dict(color="#d62728", width=2.5),
        name=f"Forecast ({horizon_days}d)",
        hovertemplate="%{x|%Y-%m-%d}<br>forecast %{y:.1f}<extra></extra>",
    ))

    # Draw the cutoff line via add_shape + add_annotation.
    # (plotly's add_vline has an internal bug that breaks when x is a Timestamp
    # or a date string combined with annotation_text.)
    cutoff_str = pd.Timestamp(cutoff).strftime("%Y-%m-%d")
    fig.add_shape(
        type="line",
        xref="x", yref="paper",
        x0=cutoff_str, x1=cutoff_str,
        y0=0, y1=1,
        line=dict(color="gray", width=1, dash="dash"),
    )
    fig.add_annotation(
        x=cutoff_str, y=1.0,
        xref="x", yref="paper",
        text="today",
        showarrow=False,
        yanchor="bottom",
        font=dict(color="gray", size=11),
    )

    fig.update_layout(
        title=dict(
            text=f"Daily Credit Consumption Forecast — {customer}",
            x=0.5, xanchor="center",
            font=dict(size=18),
        ),
        xaxis_title="Date",
        yaxis_title="Credits used",
        template="plotly_white",
        hovermode="x unified",
        legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="left", x=0),
        margin=dict(l=60, r=30, t=80, b=60),
    )

    return fig


def write_html(fig: go.Figure, output_path: str) -> None:
    # Interactive HTML: plotly.js loaded from the pinned CDN URL (nothing inlined).
    fig.write_html(
        output_path,
        include_plotlyjs=PLOTLY_CDN_URL,
        full_html=True,
        config={"responsive": True, "displaylogo": False},
    )


def write_pdf(fig: go.Figure, output_path: str) -> None:
    # Static PDF rendered via Kaleido. Requires the `kaleido` package.
    try:
        fig.write_image(output_path, format="pdf", width=1200, height=675, scale=2)
    except Exception as exc:
        raise RuntimeError(
            "Failed to write PDF. Ensure `kaleido` is installed "
            "(`pip install kaleido`)."
        ) from exc


# ──────────────────────────────────────────────
# 4. Main
# ──────────────────────────────────────────────
def main() -> int:
    slug = _slug(CUSTOMER_NAME)
    html_path = OUTPUT_HTML or f"/tmp/{slug}_forecast.html"
    pdf_path = OUTPUT_PDF or f"/tmp/{slug}_forecast.pdf"
    for p in (html_path, pdf_path):
        os.makedirs(os.path.dirname(p) or ".", exist_ok=True)

    session = Session.builder.getOrCreate()
    history = load_history(session, CUSTOMER_NAME, START_DATE, END_DATE)

    if history.empty:
        print(f"ERROR: No consumption data found for customer '{CUSTOMER_NAME}' "
              f"between {START_DATE} and {END_DATE}.")
        return 2
    if len(history) < MIN_HISTORY_DAYS:
        print(f"ERROR: Only {len(history)} days of history available "
              f"(minimum required: {MIN_HISTORY_DAYS}). Aborting forecast.")
        return 3

    print(f"Loaded {len(history)} days: "
          f"{history['USAGE_DATE'].min().date()} -> {history['USAGE_DATE'].max().date()}")
    print(f"Historical mean: {history['TOTAL_CREDITS_USED'].mean():.1f} credits/day")
    print(f"Historical std:  {history['TOTAL_CREDITS_USED'].std():.1f} credits/day")

    model, forecast = fit_and_forecast(history, FORECAST_DAYS)

    future_only = forecast[forecast["ds"] > history["USAGE_DATE"].max()]
    total_pred = float(future_only["yhat"].sum())
    mean_pred = float(future_only["yhat"].mean())
    print(f"\nForecast horizon: {FORECAST_DAYS} days")
    print(f"Predicted total credits: {total_pred:,.1f}")
    print(f"Predicted daily mean:    {mean_pred:,.1f}")

    fig = build_figure(history, forecast, CUSTOMER_NAME, FORECAST_DAYS)
    write_html(fig, html_path)
    write_pdf(fig, pdf_path)
    print(f"\nInteractive forecast HTML: {html_path}")
    print(f"(Plotly.js loaded from:   {PLOTLY_CDN_URL})")
    print(f"Static forecast PDF:      {pdf_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
