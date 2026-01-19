from google.adk.agents import LlmAgent
from schemas import CountryInput
from tools import get_capital_city

# Agent 1: Uses a tool and output_key
root_agent = LlmAgent(
    model="gemini-2.0-flash", # Hardcoded model name
    name="capital_agent_tool",
    description="Retrieves the capital city using a specific tool.",
    instruction="""You are a helpful agent that provides the capital city of a country using a tool.
The user will provide the country name in a JSON format like {"country": "country_name"}.
1. Extract the country name.
2. Use the `get_capital_city` tool to find the capital.
3. Respond clearly to the user, stating the capital city found by the tool.
""",
    tools=[get_capital_city],
    input_schema=CountryInput,
    output_key="capital_tool_result", # Store final text response
)
