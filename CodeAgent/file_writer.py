from google.adk.agents import LlmAgent
from CodeAgent.common import GEMINI_MODEL
from CodeAgent.tools import write_to_disk

# File Writer Agent
# Takes the refactored code and writes it to a file.
file_writer_agent = LlmAgent(
    name="FileWriterAgent",
    model=GEMINI_MODEL,
    instruction="""You are a File Writer Agent. Your task is to save the provided code to a structured directory.

    **Code to Save:**
    ```python
    {refactored_code}
    ```

    **Task:**
    1.  Determine a suitable project name or topic for the code (e.g., `fibonacci`, `data_processing`).
    2.  Determine a suitable filename for the python code (e.g., `main.py`, `utils.py`).
    3.  Construct the file path as: `CodeAgent/output/<project_name>/<filename>`.
    4.  Use the `write_to_disk` tool to write the code to this path.

    **Output:**
    Respond with a confirmation message stating the full path where the code was saved.
    """,
    description="Writes the refactored code to a file.",
    tools=[write_to_disk],
    # output_key is not strictly necessary if this is the last agent and we just want the response,
    # but we can capture it if needed.
)
