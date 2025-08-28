FROM python:3.11-slim

WORKDIR /helloapp

# Create non-root user for security
RUN addgroup --system app && adduser --system --ingroup app app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY helloapp/ ./helloapp

USER app
EXPOSE 8080

# Use Gunicorn WSGI server for production
ENV GUNICORN_CMD_ARGS="--bind=0.0.0.0:8080 --workers=2 --threads=2 --timeout=30"
CMD ["gunicorn", "helloapp.app:app"]
