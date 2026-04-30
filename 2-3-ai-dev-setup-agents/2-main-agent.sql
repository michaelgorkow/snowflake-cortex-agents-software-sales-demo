-- ---------------------------------------------------------
-- Main Agent - Software Sales Demo Agent
-- ---------------------------------------------------------
-- This script creates the primary Cortex Agent for the demo:
-- SOFTWARE_SALES_DEMO_AGENT. The agent supports account
-- management and sales decisions by combining:
--   * Cortex Analyst over the CUSTOMER_CONSUMPTION semantic view
--     (structured consumption/billing analytics).
--   * Cortex Search services for customer name lookup and
--     service-ticket retrieval.
--   * Web Search and Code Execution tools.
--   * A Git-sourced forecasting skill
--     (snowflake-customer-consumption-forecast).
--   * MCP servers for Slack integration and the
--     COMPETITIVE_INTELLIGENCE sub-agent.
--
-- Orchestration instructions route customer-name questions
-- through the customer-lookup tool and delegate competitive/
-- news/social-media queries to the competitive intelligence
-- sub-agent.
-- ---------------------------------------------------------

USE SCHEMA SOFTWARE_SALES_DEMO_DB.PUBLIC;

CREATE OR REPLACE AGENT SOFTWARE_SALES_DEMO_DB.PUBLIC.SOFTWARE_SALES_DEMO_AGENT
  COMMENT = 'This agent analyzes customer consumption data, service tickets, and competitive intelligence for a software sales team. It combines Snowflake analytics (via semantic model), customer lookup, service ticket search, web search, code execution, consumption forecasting, Slack integration, and a competitive intelligence sub-agent to support account management and sales decisions.'
  PROFILE = '{"display_name":"SOFTWARE_SALES_DEMO_AGENT"}'
  FROM SPECIFICATION
  $$
    {
      "models": {
        "orchestration": "claude-opus-4-7"
      },
      "orchestration": {},
      "instructions": {
        "orchestration": "**Routing**\n- Whenever a question includes customer names, use the customer-lookup tool first to identify the exact customer name.\n- Whenever a user wants to analyze news or social media for Snowflake or its competitors use the COMPETITIVE_INTELLIGENCE_AGENT_SERVER."
      },
      "tools": [
        {
          "tool_spec": {
            "type": "cortex_analyst_text_to_sql",
            "name": "customer-consumption-data",
            "description": "This tool queries Snowflake tables with customer consumption data."
          }
        },
        {
          "tool_spec": {
            "type": "cortex_search",
            "name": "customer-lookup",
            "description": "This tool allows looking up customer names."
          }
        },
        {
          "tool_spec": {
            "type": "cortex_search",
            "name": "customer-service-tickets",
            "description": "This tool allows searching through customer service tickets."
          }
        },
        {
          "tool_spec": {
            "type": "web_search",
            "name": "Web Search"
          }
        },
        {
          "tool_spec": {
            "type": "code_execution",
            "name": "code_execution"
          }
        }
      ],
      "skills": [
        {
          "name": "snowflake-customer-consumption-forecast",
          "source": {
            "type": "GIT_INTEGRATION",
            "path": "@SOFTWARE_SALES_DEMO_DB.PUBLIC.AGENT_SKILLS/branches/main/agent-skills/snowflake-customer-consumption-forecast"
          }
        }
      ],
      "mcp_servers": [
        {
          "server_spec": {
            "name": "SOFTWARE_SALES_DEMO_DB.PUBLIC.SOFTWARE_SALES_DEMO_SLACK_MCP_SERVER"
          }
        },
        {
          "server_spec": {
            "name": "SOFTWARE_SALES_DEMO_DB.COMPETITIVE_INTELLIGENCE.COMPETITIVE_INTELLIGENCE_AGENT_SERVER"
          }
        }
      ],
      "tool_resources": {
        "Web Search": {
          "max_results": 10
        },
        "code_execution": {
          "artifact_repositories": [
            "SNOWFLAKE.SNOWPARK.PYPI_SHARED_REPOSITORY"
          ],
          "external_access_integrations": [
            "SOFTWARE_SALES_DEMO_EXTERNAL_ACCESS_INTEGRATION"
          ]
        },
        "customer-consumption-data": {
          "execution_environment": {
            "type": "warehouse",
            "warehouse": ""
          },
          "semantic_view": "SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_CONSUMPTION"
        },
        "customer-lookup": {
          "columns_and_descriptions": {
            "CUSTOMER_NAME": {
              "description": "Name of the customer as it is stored in Snowflake tables.",
              "filterable": false,
              "searchable": true,
              "type": "TEXT"
            }
          },
          "id_column": "CUSTOMER_NAME",
          "max_results": 5,
          "search_service": "SOFTWARE_SALES_DEMO_DB.CUSTOMER_CONSUMPTION_DATA.CUSTOMER_SEARCH_NAME",
          "title_column": "CUSTOMER_NAME"
        },
        "customer-service-tickets": {
          "columns_and_descriptions": {
            "CUSTOMER_NAME": {
              "description": "Name of the customer",
              "filterable": false,
              "searchable": true,
              "type": "TEXT"
            },
            "TICKET_DATE": {
              "description": "Date of the service ticket",
              "filterable": false,
              "searchable": true,
              "type": "DATE"
            },
            "TICKET_DESCRIPTION": {
              "description": "Full service ticket description",
              "filterable": false,
              "searchable": true,
              "type": "TEXT"
            }
          },
          "max_results": 4,
          "search_service": "SOFTWARE_SALES_DEMO_DB.CUSTOMER_SERVICE.SERVICE_TICKET_SEARCH",
          "title_column": "CUSTOMER_NAME"
        }
      }
    }
  $$;