from google.adk.agents.config_agent_utils import from_config
import os

# Load the root agent from the YAML configuration
root_path = os.path.dirname(os.path.abspath(__file__))
root_agent = from_config(os.path.join(root_path, "root_agent.yaml"))
