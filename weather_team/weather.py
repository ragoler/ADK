from typing import Any, Optional
from google.adk.agents import Agent
from google.adk.tools import ToolContext
from weather_team.tools import get_weather

def check_city(tool: Any, args: dict, tool_context: ToolContext) -> Optional[dict]:
    """Checks if the city is Tokyo."""
    if "tokyo" in args.get("city", "").lower():
        raise ValueError("I'm sorry, I cannot look up the weather for Tokyo.")
    return None

weather_agent = Agent(
    name="weather_agent",
    model="gemini-2.5-pro",
    tools=[get_weather],
    description="This agent is a weather expert. It can provide weather forecasts for any city.",
    instruction="If the user asks for the weather, you must ask them for their favorite color first.",
)

weather_agent.before_tool_callback = check_city
