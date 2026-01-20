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
*   **`CodeAgent`**: A sequential code development pipeline (Python-based). It iterates through writing, reviewing, refactoring, and saving code to a structured directory.
*   **`CodeAgentYaml`**: A YAML-based implementation of the code development pipeline, demonstrating how to define agents and their orchestration using YAML configuration files.
*   **`basket_ball`**: A multi-agent system that can provide NBA standings and results.
*   **`multi_tool_agent`**: An agent that can use multiple tools to answer questions about the weather, time, and famous buildings in New York.
*   **`my_agent`**: A simple agent that can tell the current time in a specified city.
*   **`weather_team`**: A multi-agent system that can provide weather forecasts, greet the user, and say goodbye. It also includes a callback to check for inappropriate language.
*   **`CreativeWritingLoop`**: A writer-reviewer loop with iteration visibility and critique-driven revisions.
*   **`ParallelResearchAgent`**: A dynamic parallel research pipeline that extracts topics from user input and researches them concurrently.

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

# Run the sequential code pipeline (Python version)
echo "Write a python function that calculates factorial" | adk run CodeAgent

# Run the sequential code pipeline (YAML version)
echo "Write a python function that sorts a list" | adk run CodeAgentYaml

# Run the creative writing loop
adk run CreativeWritingLoop

# Run the parallel research pipeline
adk run ParallelResearchAgent
```


### Designing and running Agents

You can use the `adk web --port 8000` command to visualize and edit an agent.

```bash
adk web --port 8000
```

This will start a web server and open the ADK designer in your browser, where you can inspect the agent's properties, tools, and instructions.

## GKE Deployment

You can deploy the ADK web interface to Google Kubernetes Engine (GKE) for hosting.

### Prerequisites

-   Google Cloud project with billing enabled.
-   `gcloud` CLI installed and authenticated.
-   `kubectl` installed.

### Deploying to GKE

Run the provided deployment script. This script will automate the creation of a GKE Autopilot cluster, Artifact Registry repository, IAM permissions, and the Kubernetes deployment itself.

```bash
./deploy.sh
```

### Accessing the Web Interface

The service is deployed with a `ClusterIP` for security. To access it locally:

1.  **Port-forward the service:**

    ```bash
    kubectl port-forward svc/adk-web 8000:8000
    ```

2.  **Open in Browser:** Visit `http://localhost:8000`.

### Teardown

To delete all resources created by the deployment script (GKE cluster, AR repo, the GSA, and Kubernetes resources):

```bash
./deploy.sh --delete
```
