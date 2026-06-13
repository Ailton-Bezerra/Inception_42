# Maintenance Guide - Inception Project

## SSL Certificate Management

### Certificate Auto-Renewal
The project includes automatic SSL certificate management with the following features:

- **Automatic Generation**: Certificates are generated on first startup
- **Expiration Check**: Expired certificates are automatically regenerated
- **Validity Period**: Certificates are valid for 365 days
- **Domain**: Certificate is issued for the domain specified in `DOMAIN_NAME` env variable

### Certificate Details
- **Location**: `/etc/nginx/ssl/` inside the nginx container
- **Files**:
  - `nginx.crt` - Public certificate
  - `nginx.key` - Private key (RSA 2048-bit)
- **Algorithm**: RSA 2048-bit encryption

### Troubleshooting SSL Issues

#### Symptom: `PR_END_OF_FILE_ERROR` in browser
This error typically indicates:
1. NGINX container failed to start
2. SSL certificate missing or invalid
3. NGINX configuration has errors

**Solution**:
```bash
cd srcs
docker-compose logs nginx  # Check logs for errors
docker-compose down
docker-compose build --no-cache nginx  # Force rebuild
docker-compose up -d
```

#### Regenerating Certificates Manually
```bash
cd srcs
docker-compose exec nginx rm -f /etc/nginx/ssl/nginx.crt /etc/nginx/ssl/nginx.key
docker-compose restart nginx
```

## Health Checks

The nginx container includes automated health checks:
- **Interval**: Every 10 seconds
- **Timeout**: 5 seconds
- **Retries**: 3 attempts before marking unhealthy
- **Start Period**: 10 seconds (grace period on startup)

Check container health:
```bash
docker-compose ps  # Status column shows health
docker-compose exec nginx wget --no-verbose --tries=1 --spider https://localhost/
```

## Configuration Validation

The entrypoint script now validates:
1. ✅ SSL certificate existence
2. ✅ SSL certificate validity (not expired)
3. ✅ SSL certificate and key readability
4. ✅ NGINX configuration syntax (`nginx -t`)
5. ⚠️ Upstream connectivity (optional, via `VERIFY_UPSTREAM=true`)

## Best Practices

### 1. Environment Variables
Always ensure `.env` file is present and has required variables:
```bash
# .env should include:
DOMAIN_NAME=ailbezer.42.fr
# Other WordPress/MariaDB variables...
```

### 2. Regular Backups
Keep backups of:
- `.env` file
- SSL certificates (mounted volume)
- WordPress data (mounted volume)

### 3. Logs Monitoring
Regularly check logs for warnings:
```bash
docker-compose logs -f nginx
docker-compose logs -f wordpress
docker-compose logs -f mariadb
```

### 4. Certificate Monitoring
Check certificate expiration date:
```bash
docker-compose exec nginx openssl x509 -in /etc/nginx/ssl/nginx.crt -noout -dates
```

### 5. Clean Rebuild
If experiencing issues, perform a clean rebuild:
```bash
docker-compose down
docker system prune -a --volumes  # ⚠️ Be careful with this!
docker-compose build --no-cache
docker-compose up -d
```

## Container Dependencies

Startup order:
1. **MariaDB** (no dependencies)
2. **WordPress** (depends on MariaDB)
3. **NGINX** (depends on WordPress)

All containers have `restart: always` policy for automatic recovery.

## Volumes

Volumes use bind mounts to persist data:
```
mariadb_data   → /home/ailbezer/data/mariadb
wordpress_data → /home/ailbezer/data/wordpress
```

These directories must exist and be writable by Docker.

## Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| NGINX won't start | Config error | Check `docker-compose logs nginx` |
| PR_END_OF_FILE_ERROR | NGINX crashed | Rebuild without cache: `docker-compose build --no-cache` |
| Certificate expired | Time-based | Container will auto-regenerate on next start |
| Can't connect to WordPress | Container not ready | Wait for health check to pass |
| Volume mount errors | Permissions | Check directory permissions: `ls -ld /home/ailbezer/data/` |

## Updating Configuration

After updating nginx config or any Dockerfile:
```bash
cd srcs
docker-compose build --no-cache <service>  # nginx, wordpress, mariadb
docker-compose up -d
```

## Testing

Verify the setup is working:
```bash
# Check all services are running
docker-compose ps

# Test HTTPS connection
curl -k https://ailbezer.42.fr

# Check certificate
openssl s_client -connect localhost:443 </dev/null

# Monitor logs in real-time
docker-compose logs -f
```
