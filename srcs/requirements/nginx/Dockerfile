FROM alpine:3.19

# Instala nginx e openssl
RUN apk update && apk add --no-cache nginx openssl

# Cria diretórios necessários
RUN mkdir -p /etc/nginx/ssl /run/nginx

# Gera certificado TLS self-signed (obrigatório usar HTTPS)
RUN openssl req -x509 -nodes -days 365 \
    -subj "/C=BR/ST=SP/O=42SP/CN=ailton.42.fr" \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt

# Copia o nginx.conf customizado
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Exponha a porta HTTPS
EXPOSE 443

# Execução no foreground
CMD ["nginx", "-g", "daemon off;"]
