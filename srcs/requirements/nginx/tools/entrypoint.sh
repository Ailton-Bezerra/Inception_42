#!/bin/sh
set -e

SSL_DIR="/etc/nginx/ssl"
DOMAIN="${DOMAIN_NAME:-localhost}"

# Create SSL directory if it doesn't exist
mkdir -p "$SSL_DIR"

# Generate self-signed certificate only if it doesn't exist
if [ ! -f "$SSL_DIR/nginx.crt" ] || [ ! -f "$SSL_DIR/nginx.key" ]; then
    echo "[INFO] Generating SSL certificate for domain: $DOMAIN"
    openssl req -x509 -nodes -days 365 \
        -subj "/C=BR/ST=SP/O=42SP/CN=${DOMAIN}" \
        -newkey rsa:2048 \
        -keyout "$SSL_DIR/nginx.key" \
        -out "$SSL_DIR/nginx.crt"
    echo "[INFO] SSL certificate generated successfully"
else
    echo "[INFO] SSL certificate already exists"
fi

echo "[INFO] Starting NGINX..."
exec nginx -g "daemon off;"
