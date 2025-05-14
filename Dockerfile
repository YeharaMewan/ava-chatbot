# Use an appropriate base image
FROM ghcr.io/astral-sh/uv:python3.10-bookworm-slim

# Install the project into `/app`
WORKDIR /app

# Set environment variables (e.g., set Python to run in unbuffered mode)
ENV PYTHONUNBUFFERED 1

# Install system dependencies for building libraries
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy the dependency management files (lock file and pyproject.toml) first
COPY uv.lock pyproject.toml README.md /app/

# Install the application dependencies
RUN uv sync --frozen --no-cache || pip install triton==3.1.0 --no-deps

# Copy your application code into the container
COPY src/ /app/

# Set the virtual environment environment variables
ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

# Install the package in editable mode
RUN uv pip install -e .

# Define volumes
VOLUME ["/app/data"]

# Expose the port
EXPOSE 8070

# Run the FastAPI app using uvicorn
CMD ["/app/.venv/bin/fastapi", "run", "ai_companion/interfaces/whatsapp/webhook_endpoint.py", "--port", "8070", "--host", "0.0.0.0"]
