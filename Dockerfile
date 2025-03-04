# Use Python 3.9 on Alpine Linux
FROM python:3.9-alpine3.13

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apk add --update --no-cache postgresql-dev gcc python3-dev musl-dev libffi-dev openssl-dev

# Copy the requirements files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Set the working directory
WORKDIR /app

# Copy the application code
COPY ./app /app

# Expose port 8000
EXPOSE 8000

# Argument to determine if dev dependencies should be installed
ARG DEV=false

# Create a virtual environment, install dependencies, and clean up
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Add the virtual environment to the PATH
ENV PATH="/py/bin:$PATH"

# Switch to the non-root user
USER django-user

# Default command (can be overridden in docker-compose)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]