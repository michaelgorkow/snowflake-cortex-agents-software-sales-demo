-- ---------------------------------------------------------
-- Competitive Intelligence Sub-Agent
-- ---------------------------------------------------------
-- This script creates the COMPETITIVE_INTELLIGENCE schema and
-- provisions a Cortex sub-agent focused on analyzing news and
-- social media content about Snowflake and its competitors.
--
-- It configures:
--   * COMPETITIVE_INTELLIGENCE_AGENT - a Cortex Agent with a
--     Web Search tool and a GIT-sourced skill
--     (snowflake-competitor-news-social-media) loaded from the
--     AGENT_SKILLS Git repository.
--   * COMPETITIVE_INTELLIGENCE_AGENT_SERVER - an MCP server that
--     exposes the sub-agent as a callable tool so the main demo
--     agent can invoke it via CORTEX_AGENT_RUN.
-- ---------------------------------------------------------

CREATE OR REPLACE SCHEMA SOFTWARE_SALES_DEMO_DB.COMPETITIVE_INTELLIGENCE;

CREATE OR REPLACE AGENT SOFTWARE_SALES_DEMO_DB.COMPETITIVE_INTELLIGENCE.COMPETITIVE_INTELLIGENCE_AGENT
  COMMENT = 'This agent provides tools and skills to analyze news and social media content for Snowflake and its competitors.'
  PROFILE = '{"display_name":"COMPETITIVE_INTELLIGENCE_AGENT"}'
  FROM SPECIFICATION
  $$
    {
      "models": {
        "orchestration": "claude-sonnet-4-6"
      },
      "orchestration": {},
      "instructions": {
        "sample_questions": [
          {
            "question": "Analyze social media content about Snowflake and its competitors for the current month."
          }
        ]
      },
      "tools": [
        {
          "tool_spec": {
            "type": "web_search",
            "name": "Web Search"
          }
        }
      ],
      "skills": [
        {
          "name": "snowflake-competitor-news-social-media",
          "source": {
            "type": "GIT_INTEGRATION",
            "path": "@SOFTWARE_SALES_DEMO_DB.PUBLIC.AGENT_SKILLS/branches/main/agent-skills/snowflake-competitor-news-social-media"
          }
        }
      ],
      "tool_resources": {
        "Web Search": {
          "max_results": 10
        }
      }
    }
  $$;


CREATE OR REPLACE MCP SERVER SOFTWARE_SALES_DEMO_DB.COMPETITIVE_INTELLIGENCE.COMPETITIVE_INTELLIGENCE_AGENT_SERVER
  FROM SPECIFICATION $$
    tools:
      - title: "Competetive Agent"
        name: "COMPETETIVE_INTELLIGENCE_AGENT"
        type: "CORTEX_AGENT_RUN"
        identifier: "SOFTWARE_SALES_DEMO_DB.COMPETITIVE_INTELLIGENCE.COMPETITIVE_INTELLIGENCE_AGENT"
        description: "Cortex agent that has tools and skills to analyze news and social media content for Snowflake and its competitors."
  $$;