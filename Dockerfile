FROM python:3.11-slim

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# If your Flask app listens on a different port, change this
EXPOSE 5000

# Environment variables for Flask apps (adjust if needed)
ENV FLASK_APP=main.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV PYTHONUNBUFFERED=1

# If your entry file is not main.py, change it here
CMD ["python", "main.py"]

