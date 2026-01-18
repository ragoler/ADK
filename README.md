# Antigravity ADK Project

This project contains a collection of agents built with the Google Agent Development Kit (ADK).

## Agents

This project includes the following agents:

*   **weather_team**: A multi-agent system that can provide weather forecasts.
*   **multi_tool_agent**: An agent that can use multiple tools to answer questions about weather, time, and famous buildings.
*   **my_agent**: A simple agent.
*   **adk-streaming**: An agent that demonstrates the streaming capabilities of the ADK.

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

    Each agent has its own `.env` file. Before running an agent, make sure to configure the corresponding `.env` file with your API keys.

    For example, for the `weather_team` agent, you need to configure `weather_team/.env`.

4.  **Run an agent:**

    You can run an agent using the `adk run` command. For example, to run the `weather_team` agent:

    ```bash
    adk run weather_team
    ```

    To run the streaming agent in a web UI:

    ```bash
    adk web adk-streaming/app
    ```
