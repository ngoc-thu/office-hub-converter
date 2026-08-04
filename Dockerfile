FROM gotenberg/gotenberg:8

USER root

# Install Nginx and curl
RUN apt-get update && apt-get install -y nginx curl procps && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/sites-available/default
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
