from google.adk.tools.tool_context import ToolContext
from google.adk.agents.callback_context import CallbackContext

def initialize_topics(callback_context: CallbackContext) -> None:
    """Ensures all topic keys exist in state to avoid KeyError."""
    for i in range(1, 4):
        key = f'topic_{i}'
        if key not in callback_context.state:
            callback_context.state[key] = ""
    for i in range(1, 4):
        key = f'research_{i}'
        if key not in callback_context.state:
            callback_context.state[key] = "No research performed."

def set_topics(topic_1: str, topic_2: str = "", topic_3: str = "", *, tool_context: ToolContext) -> str:
    """Sets the research topics in the session state.
    
    Args:
        topic_1: The first research topic.
        topic_2: The second research topic (optional).
        topic_3: The third research topic (optional).
    """
    tool_context.state['topic_1'] = topic_1
    tool_context.state['topic_2'] = topic_2
    tool_context.state['topic_3'] = topic_3
    return f"Topics set: 1) {topic_1}; 2) {topic_2}; 3) {topic_3}"
