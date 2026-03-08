from google.adk.agents import Agent

greeter_agent = Agent(
    name="greeter_agent",
    model=os.getenv("GOOGLE_GENAI_MODEL_NAME", "gemini-2.5-pro"),
    description="This agent is a greeter. It can greet users and say hello.",
)
