from google.adk.agents import Agent

greeter_agent = Agent(
    name="greeter_agent",
    model="gemini-2.5-pro",
    description="This agent is a greeter. It can greet users and say hello.",
)
