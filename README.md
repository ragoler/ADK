# ADK Tutorial

This project contains a collection of agents built with the Google Agent Development Kit (ADK).

## Getting Started

This project uses the Google Agent Development Kit (ADK). For more information about the ADK, please refer to the official documentation: [https://google.github.io/adk-docs/get-started](https://google.github.io/adk-docs/get-started).

### Prerequisites

*   Python 3.11 or later
*   Git

### Cloning the Repository

To clone this repository, run the following command:

```bash
git clone https://github.com/ragoler/ADK.git
cd ADK
```

### Installation and Usage

1.  **Create and activate a virtual environment:**

    ```bash
    python -m venv .venv
    source .venv/bin/activate
    ```

2.  **Install the dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

3.  **Set up your API keys:**

    Some agents may require API keys to function. These are configured in a `.env` file within the agent's directory. Before running an agent, make sure to configure the corresponding `.env` file with your API keys.

## The Agents

This project includes the following agents, each located in its own directory:

*   **`adk-streaming`**: A simple agent that uses Google Search to answer questions, demonstrating the streaming capabilities of the ADK.
*   **`all_together_agent`**: An example based on the "Putting it all together" section of the ADK documentation. It demonstrates two agents: one that uses a tool to find the capital of a country, and another that uses an output schema to provide structured information.
*   **`basket_ball`**: A multi-agent system that can provide NBA standings and results.
*   **`multi_tool_agent`**: An agent that can use multiple tools to answer questions about the weather, time, and famous buildings in New York.
*   **`my_agent`**: A simple agent that can tell the current time in a specified city.
*   **`weather_team`**: A multi-agent system that can provide weather forecasts, greet the user, and say goodbye. It also includes a callback to check for inappropriate language.

### Running the Agents

You can run any of the agents interactively from the root of the project using the `adk run <agent_directory>` command. 

**Examples:**

```bash
# Run the simple time-telling agent
adk run my_agent

# Run the multi-tool agent
adk run multi_tool_agent

# Run the weather team multi-agent system
adk run weather_team
```

### Special Instructions for `all_together_agent`

The `all_together_agent` has its own dependencies. To install them, run:

```bash
pip install -r all_together_agent/requirements.txt
```

To run the agent that uses a tool:

```bash
adk run all_together_agent
```

To see both agents in action as described in the documentation, run the `main.py` script:

```bash
python all_together_agent/main.py
```

### Designing the Agents

You can use the `adk design <agent_directory>` command to visualize and edit an agent.

```bash
adk design all_together_agent
```

This will start a web server and open the ADK designer in your browser, where you can inspect the agent's properties, tools, and instructions.
