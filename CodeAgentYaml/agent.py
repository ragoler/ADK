from google.adk.agents.config_agent_utils import from_config

# Load the root agent from the YAML file
# The YAML loader will handle resolving CodeAgentYaml.tools.write_to_disk
root_agent = from_config("CodeAgentYaml/root_agent.yaml")
