from google.adk.agents import LlmAgent
from CodeAgent.common import GEMINI_MODEL

# Code Refactorer Agent
# Takes the original code and the review comments (read from state) and refactors the code.
code_refactorer_agent = LlmAgent(
    name="CodeRefactorerAgent",
    model=GEMINI_MODEL,
    instruction="""You are a Python Code Refactoring AI. Your goal is to improve the given Python code based on the provided review comments.

    **Original Code:**
    ```python
    {generated_code}
    ```

    **Review Comments:**
    {review_comments}

    **Task:**
    Carefully apply the suggestions from the review comments to refactor the original code.
    If the review comments state "No major issues found," return the original code unchanged.
    Ensure the final code is complete, functional, and includes necessary imports and docstrings.

    **Output:**
    Output *only* the final, refactored Python code block, enclosed in triple backticks (```python ... ```).
    Do not add any other text before or after the code block.
    """,
    description="Refactors code based on review comments.",
    output_key="refactored_code", # Stores output in state['refactored_code']
)
