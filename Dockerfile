# Use a slim Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies if any (none required for adk web usually)
# RUN apt-get update && apt-get install -y ...

# Copy requirements and install
COPY requirements.txt .
ARG PIP_INDEX_URL
RUN pip install --no-cache-dir \
    ${PIP_INDEX_URL:+--index-url $PIP_INDEX_URL} \
    -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port used by adk web
EXPOSE 8000

# Set the entrypoint to run adk web
# We use --host 0.0.0.0 to allow external connections within the cluster
ENTRYPOINT ["adk", "web", "--port", "8000", "--host", "0.0.0.0"]
