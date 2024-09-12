# Use a specific tag for the base image for stability
FROM python:3.9-alpine AS builder

# Set the working directory
WORKDIR /app

# Create and activate a virtual environment
RUN python3 -m venv venv
ENV VIRTUAL_ENV=/app/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Copy requirements file and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Stage 2: Use a fresh base image for the runtime environment
FROM python:3.9-alpine AS runner

# Set the working directory
WORKDIR /app

# Copy virtual environment and application files from the builder stage
COPY --from=builder /app/venv /app/venv
COPY app.py /app/app.py
COPY templates/ /app/templates/

# Set environment variables
ENV VIRTUAL_ENV=/app/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV FLASK_APP=/app/app.py

# Expose the port for the application
EXPOSE 8080

# Start the application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
