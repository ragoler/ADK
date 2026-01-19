from google.adk.agents import SequentialAgent
from CodeAgent.writer import code_writer_agent
from CodeAgent.reviewer import code_reviewer_agent
from CodeAgent.refactorer import code_refactorer_agent
from CodeAgent.file_writer import file_writer_agent

# --- 2. Create the SequentialAgent ---
# This agent orchestrates the pipeline by running the sub_agents in order.
code_pipeline_agent = SequentialAgent(
    name="CodePipelineAgent",
    sub_agents=[code_writer_agent, code_reviewer_agent, code_refactorer_agent, file_writer_agent],
    description="Executes a sequence of code writing, reviewing, refactoring, and saving to disk.",
    # The agents will run in the order provided: Writer -> Reviewer -> Refactorer -> FileWriter
)

# For ADK tools compatibility, the root agent must be named `root_agent`
root_agent = code_pipeline_agent
