import random

def get_weather(city: str) -> str:
    """Looks up the weather for a given city."""
    if "sydney" in city.lower():
        return "The weather in Sydney is 25 degrees and sunny."
    elif "melbourne" in city.lower():
        return "The weather in Melbourne is 18 degrees and cloudy."
    else:
        return f"The weather in {city} is {random.randint(10, 30)} degrees."