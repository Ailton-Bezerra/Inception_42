# Inception

*This project has been created as part of the 42 curriculum by ailbezer.*

## Description

Inception is a comprehensive infrastructure project that demonstrates containerization and orchestration using Docker and Docker Compose. The goal of this project is to build a complete WordPress environment consisting of three main services: a web server (Nginx), a content management system (WordPress), and a relational database (MariaDB).

The project showcases best practices in:
- **Container architecture**: Implementing isolated services that communicate through a defined network
- **Data persistence**: Using volumes to maintain data across container restarts
- **Environment configuration**: Managing secrets and environment variables securely
- **Process orchestration**: Coordinating multiple interdependent services

This project is ideal for understanding how production-like web applications are deployed using containerization, making it suitable for learning DevOps fundamentals and cloud-native application architecture.

## Instructions

### Prerequisites

Before running this project, ensure you have the following installed:
- Docker (version 20.10 or higher)
- Docker Compose (version 1.29 or higher)
- A Unix-like system (Linux, macOS, or WSL2 on Windows)

### Installation and Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url> inception
   cd inception
   ```

2. **Configure domain in `/etc/hosts`**:
   ⚠️ **IMPORTANT**: Add the following line to your system's `/etc/hosts` file:
   ```bash
   sudo nano /etc/hosts  # or vi/vim
   # Add this line:
   127.0.0.1  ailbezer.42.fr
   ```
   This maps the domain to your local machine. Replace `ailbezer.42.fr` with your actual domain if different.

3. **Configure environment variables**:
   The project requires environment variables to be set. Copy `.env.example` to `.env` and configure:
   ```bash
   cp srcs/.env.example srcs/.env
   nano srcs/.env  # Edit with your values
   ```
   
   Required variables:
   ```
   # Database
   MYSQL_HOST=mariadb
   MYSQL_DATABASE=wordpress
   MYSQL_USER=wpuser
   MYSQL_PASSWORD=your_secure_password
   MYSQL_ROOT_PASSWORD=your_root_password
   
   # WordPress Site
   WP_URL=https://ailbezer.42.fr
   WP_TITLE=My Inception Site
   WP_ADMIN=inception  # Note: cannot contain "admin"
   WP_ADMIN_PASSWORD=your_secure_password
   WP_ADMIN_EMAIL=admin@example.com
   
   # Domain
   DOMAIN_NAME=ailbezer.42.fr
   
   # Additional User (optional)
   WP_USER=editor
   WP_USER_PASSWORD=secure_password
   WP_USER_EMAIL=user@example.com
   ```
   
   ⚠️ **Security Note**: The `.env` file is ignored by git and should contain strong passwords. Use the `.env.example` only as a template.

4. **Start the infrastructure**:
   ```bash
   make up
   ```
   This command will:
   - Create necessary directories for data persistence
   - Build Docker images from the provided Dockerfiles
   - Start all three containers (MariaDB, WordPress, Nginx)

### Common Commands

- **Start the services**: `make up`
- **Stop the services**: `make down`
- **Rebuild and restart**: `make build`
- **View logs**: `make logs`
- **Check status**: `make status`
- **Access WordPress shell**: `make shell`
- **Clean everything** (containers, volumes, images): `make clean`
- **Get help**: `make help`

### Accessing the Application

Once the services are running:
- **WordPress Admin**: Navigate to `https://ailbezer.42.fr/wp-admin/` (use the credentials from your `.env` file)
- **Website**: Access `https://ailbezer.42.fr/`
- **Database**: MariaDB runs on port 3306 (accessible from within the network)

### Troubleshooting

- **Port conflicts**: If port 443 are already in use, modify the port mappings in `docker-compose.yml`
- **Database connection failures**: Ensure the database container has fully started before WordPress tries to connect (the entrypoint script handles this with retry logic)
- **Volume permissions**: On Linux, ensure proper permissions on the `/home/ailbezer/data/` directories
- **View logs**: Run `make logs` to see detailed output from all containers

## Project Description

### Docker Architecture and Design Choices

This project demonstrates a multi-container application architecture where each service runs in its own isolated container with its own filesystem, processes, and network interface. The three containers are orchestrated using Docker Compose, which simplifies the startup, shutdown, and networking of multiple related containers.

#### Main Design Decisions:

1. **Alpine Linux Base Images**: All containers use Alpine Linux (3.19) as the base image to minimize image size and attack surface, following the principle of container minimalism.

2. **Health Checks**: Environment variable-driven configuration through `.env` files allows for flexible deployment across different environments without modifying code.

3. **Data Persistence**: The project uses named volumes with bind mounts to ensure that database and application data persist even after containers are stopped or removed.

4. **Network Isolation**: A custom bridge network (`inception`) is created to allow secure internal communication between containers while isolating them from other containers on the host.

#### Architectural Comparisons:

##### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|-----------------|-------------------|
| **Overhead** | Large (full OS per VM) | Small (shared kernel) |
| **Startup Time** | Minutes | Seconds |
| **Resource Usage** | High (GB per VM) | Low (MB per container) |
| **Image Size** | Gigabytes | Megabytes |
| **Isolation** | Complete OS isolation | Process-level isolation |
| **Use Case** | Full environment isolation | Application isolation |

**Choice for this project**: Docker provides sufficient isolation for application-level services while maintaining lightweight, fast-starting containers ideal for development and deployment.

##### Secrets Management: Secrets vs Environment Variables

| Aspect | Environment Variables | Docker Secrets |
|--------|----------------------|-----------------|
| **Storage** | In `.env` files or system environment | Docker Swarm secret store (encrypted) |
| **Scope** | Global or container-wide | Mounted as files in specific services |
| **Encryption** | None (plain text) | Encrypted at rest |
| **Git Safety** | Risky if `.env` committed | Safer (not stored in files) |
| **Simplicity** | Easy to configure | Requires Docker Swarm mode |

**Choice for this project**: Environment variables via `.env` file are used, with the assumption that the `.env` file is listed in `.gitignore`. This balances simplicity for development with the understanding that `.env` files containing sensitive data should never be committed to version control.

##### Docker Network: Bridge Network vs Host Network

| Aspect | Bridge Network | Host Network |
|--------|----------------|--------------|
| **Isolation** | Containers have isolated network namespace | Container shares host's network |
| **Port Mapping** | Required to expose ports | Ports directly accessible |
| **Inter-container Communication** | Via container names (DNS) | Via localhost or host IP |
| **Performance** | Slight overhead from nat | Minimal overhead |
| **Security** | Better isolation | Less isolation |

**Choice for this project**: A custom bridge network (`inception`) is used because it:
- Provides automatic DNS resolution between containers using container names
- Isolates the application's network from other containers
- Allows flexible port mapping while maintaining internal communication via container names
- Works seamlessly across different environments

##### Storage: Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|----------------|------------|
| **Location** | Docker-managed directory | Any location on host |
| **Performance** | Optimized, especially on Docker Desktop | Direct filesystem access |
| **Portability** | Works across different hosts | Host-specific paths |
| **Permissions** | Docker manages them | Host filesystem permissions apply |
| **Data Sharing** | Between containers | With host and containers |

**Choice for this project**: Bind mounts are used with Docker volumes due to the following reasons:
- Allows direct access to data files on the host system for backup and inspection
- Specific paths (`/home/ailbezer/data/mariadb` and `/home/ailbezer/data/wordpress`) are known and management-friendly
- Suitable for development environments where host filesystem access is valuable
- In production, pure Docker volumes would be preferred for better portability

#### Configuration Flow:

1. **Initialization (First Run)**:
   - MariaDB entrypoint initializes the database, creates users, and sets up privileges
   - WordPress entrypoint waits for MariaDB, downloads WordPress, creates configuration, and installs the site

2. **Data Persistence**:
   - Database files stored in `/home/ailbezer/data/mariadb`
   - WordPress files stored in `/home/ailbezer/data/wordpress`
   - Both persist across container restarts and system reboots

3. **Network Communication**:
   - WordPress connects to MariaDB using the hostname `mariadb` (Docker DNS resolution)
   - Nginx proxies requests to WordPress container
   - All internal communication happens within the `inception` bridge network

## Resources

### Documentation and References

- **Docker Official Documentation**: https://docs.docker.com/
- **Docker Compose Documentation**: https://docs.docker.com/compose/
- **WordPress Handbook**: https://developer.wordpress.org/
- **Nginx Documentation**: https://nginx.org/en/docs/
- **MariaDB Knowledge Base**: https://mariadb.com/kb/
- **Alpine Linux Documentation**: https://wiki.alpinelinux.org/
- **WP-CLI Documentation**: https://developer.wordpress.org/cli/commands/

### Articles and Tutorials

- Docker Best Practices: https://docs.docker.com/develop/dev-best-practices/
- Understanding Docker Networking: https://docs.docker.com/network/
- WordPress with Docker: https://docs.docker.com/samples/wordpress/
- Nginx as a Reverse Proxy: https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/

### External Tools Used

- **WP-CLI**: Command-line interface for WordPress, used in the WordPress container for automated installation
- **Alpine Linux**: Lightweight Linux distribution used as the base for all containers
- **MariaDB**: Open-source relational database management system

### AI Usage

AI was utilized for the following aspects of this project:

1. **Documentation and README Creation**: Helped structure and write comprehensive documentation covering architectural decisions, comparisons between different approaches, and troubleshooting guides.

2. **Docker Configuration Optimization**: Assisted in optimizing Dockerfiles by suggesting best practices such as:
   - Multi-stage builds if needed
   - Layer caching optimization
   - Alpine Linux usage for minimal image sizes

3. **Entrypoint Script Development**: Helped design robust shell scripts with:
   - Proper error handling and exit codes
   - Health checks and retry logic for database connectivity
   - Conditional installation to handle container restarts gracefully
   - Environment variable integration and validation

4. **Docker Compose Configuration**: Provided guidance on:
   - Service dependency management
   - Network configuration and connectivity patterns
   - Volume setup with bind mounts
   - Environment variable handling

The AI contributions focused on ensuring production-like best practices while maintaining simplicity and educational clarity appropriate for a learning project.

## License

This project is part of the 42 school curriculum and is provided under the terms specified in the LICENSE file.

## Author

**ailbezer** - 42 Student
