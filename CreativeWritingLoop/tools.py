from google.adk.tools import tool_context
from google.adk.agents.callback_context import CallbackContext
from google.adk.models.llm_request import LlmRequest

def initialize_state(callback_context: CallbackContext) -> None:
    """Ensures that required state variables exist to avoid Template KeyError."""
    if 'current_draft' not in callback_context.state:
        callback_context.state['current_draft'] = 'No draft yet.'
    if 'feedback' not in callback_context.state:
        callback_context.state['feedback'] = 'No feedback yet.'
    if 'iteration' not in callback_context.state:
        callback_context.state['iteration'] = 0

def increment_iteration(callback_context: CallbackContext) -> None:
    """Increments the iteration counter in session state."""
    current_iter = callback_context.state.get('iteration', 0)
    callback_context.state['iteration'] = current_iter + 1

def inject_iteration_to_state(callback_context: CallbackContext) -> None:
    """Pass-through to ensure 'iteration' is available (if needed)."""
    if 'iteration' not in callback_context.state:
        callback_context.state['iteration'] = 1

from google.adk.tools.tool_context import ToolContext

def finish_writing(summary: str, tool_context: ToolContext) -> str:
    """Considers the writing task complete and exits the loop.
    
    Args:
        summary: A brief summary of the final work.
        tool_context: The context of the tool call, provided by ADK.
    """
    tool_context.actions.escalate = True
    return f"Task completed: {summary}"
