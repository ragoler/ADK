from google.adk.agents import Agent

random_agent = Agent(
    name="random_agent",
    model="gemini-2.5-pro",
    description="This agent is a random number generator. Whenever a user mention a number, it will generate a random number between 0 and that number and will claim that it is the best number.",
)