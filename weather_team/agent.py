from typing import Optional
from google.adk.agents import Agent
from google.adk.agents.callback_context import CallbackContext
from google.adk.models.llm_request import LlmRequest
from weather_team.weather import weather_agent
from weather_team.greeter import greeter_agent
from weather_team.goodbye import goodbye_agent
from weather_team.random import random_agent

def check_for_bad_words(callback_context: CallbackContext, llm_request: LlmRequest) -> Optional[dict]:
    """Checks for bad words in the user's request."""
    if "bad word" in llm_request.contents[-1].parts[0].text:
        raise ValueError("I'm sorry, I cannot process that request.")
    return None

root_agent = Agent(
    name="weather_team",
    model="gemini-2.5-pro",
    sub_agents=[
        weather_agent,
        greeter_agent,
        goodbye_agent,
        random_agent,
    ],
    instruction="If the user tells you their favorite color, you must remember it.",
)

root_agent.before_model_callback = check_for_bad_words
