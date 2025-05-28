FROM python:slim

# Create a non-root user for security
RUN groupadd -r automx2 && useradd -r -g automx2 automx2

# Install the automx2 package, the application server gunicorn and the template engine Jinja2
# https://rseichter.github.io/automx2/#install
RUN pip install automx2 gunicorn Jinja2

# Create directories with proper permissions
RUN mkdir -p /data /app/config && \
    chown automx2:automx2 /data /app/config

# Copy custom files
COPY automx2.template.conf /app/config/
COPY start.py /app/
COPY check.py /app/

# Make scripts executable and set ownership
RUN chmod +x /app/start.py /app/check.py && \
    chown -R automx2:automx2 /app

# Switch to non-root user
USER automx2

# Set working directory
WORKDIR /app

# Start the container with a custom start script
CMD ["/app/start.py"]
EXPOSE 4243
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s CMD /app/check.py