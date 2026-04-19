#!/bin/sh
set -e

SSL_DIR="/etc/nginx/ssl"
DOMAIN="${DOMAIN_NAME:-localhost}"

mkdir -p "$SSL_DIR"

if [ ! -f "$SSL_DIR/nginx.crt" ] || [ ! -f "$SSL_DIR/nginx.key" ]; then
    echo ">> Generating SSL certificate for domain: $DOMAIN"
    openssl req -x509 -nodes -days 365 \
        -subj "/C=BR/ST=SP/O=42SP/CN=${DOMAIN}" \
        -newkey rsa:2048 \
        -keyout "$SSL_DIR/nginx.key" \
        -out "$SSL_DIR/nginx.crt"
    echo ">> SSL certificate generated successfully"
else
    echo ">> SSL certificate already exists"
fi

echo ">> Starting NGINX..."
exec nginx -g "daemon off;"
