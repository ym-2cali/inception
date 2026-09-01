*This project has been created as part of the 42 curriculum by yael-maa.*

# Inception

## Description

The goal of the **Inception** project is to broaden system administration and DevOps knowledge using Docker. The project consists of setting up a secure, multi-container web infrastructure running on a Linux Mint Virtual Machine following strict deployment rules.

The infrastructure runs on Debian Bookworm and consists of three isolated services:
1. **NGINX**: The single entry point to the infrastructure, exposing only port 443 with TLSv1.2/TLSv1.3 encryption.
2. **WordPress**: The application server running WordPress with PHP-FPM 8.2 (listening internally on port 9000).
3. **MariaDB**: The database engine holding WordPress tables and user data (listening internally on port 3306).

All services run inside a dedicated Docker bridge network (`inception`), communicating privately without exposing internal database or application ports directly to the host.

### Technical & Architectural Comparisons

#### 1. Virtual Machines vs Docker Containers
- **Virtual Machines (VMs)**: Emulate complete hardware environments and run full guest operating systems with independent kernels on top of a hypervisor. This provides strong isolation at the expense of heavy resource consumption (RAM, CPU, disk space) and slower boot times.
- **Docker Containers**: Share the host OS kernel and package only the application binaries and runtime dependencies in user space. They are lightweight, start in seconds, consume minimal resources, and provide efficient process-level isolation through Linux namespaces and cgroups.

#### 2. Secrets vs Environment Variables
- **Environment Variables**: Simple mechanism for passing runtime configurations (such as database names, ports, and hostnames). However, they can be inspected via `docker inspect`, process listings (`/proc`), or build logs if not carefully managed.
- **Docker Secrets**: Designed specifically for sensitive credentials (passwords, SSL private keys, API tokens). In production and orchestrators (like Docker Swarm), secrets are mounted in-memory only inside the container filesystem (`/run/secrets/`), preventing leaks in logs or inspect outputs. In local environments, strict file permissions on `.env` files and restricted access are standard alternatives.

#### 3. Docker Network vs Host Network
- **Docker Bridge Network**: Creates an isolated virtual software bridge. Containers receive private IP addresses and resolve each other via internal DNS (container names). Only explicitly published ports are accessible from outside, keeping backend database traffic isolated.
- **Host Network**: Attaches containers directly to the host’s network stack, sharing the host IP and port space without isolation. While offering slightly lower networking overhead, it removes namespace isolation and creates risks of port conflicts.

#### 4. Docker Volumes vs Bind Mounts
- **Docker Named Volumes**: Managed entirely by the Docker engine in a dedicated storage location (`/var/lib/docker/volumes/`). They are portable, easier to back up, and abstract host-specific paths.
- **Bind Mounts**: Directly mount an exact host filesystem directory into a container (e.g., `/home/yael-maa/data/wordpress`). They allow direct access and persistence tied to specific host locations, making them ideal when data must reside in designated host paths.

---

## Instructions

### Prerequisites
- **Target OS**: Linux Mint (Virtual Machine or native)
- **Required Packages**: `docker.io`, `docker-compose-v2`, `make`, `curl`

### Host Setup on Linux Mint VM
1. **Map domain name** `yael-maa.42.fr` to `127.0.0.1` in `/etc/hosts`:
   ```bash
   echo "127.0.0.1 yael-maa.42.fr" | sudo tee -a /etc/hosts
   ```

2. **Add your user to the `docker` group**:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. **Ensure Docker service is running**:
   ```bash
   sudo service docker start
   ```

### Execution Commands
All actions are driven by the `Makefile` at the root of the repository:

- **Build and start the infrastructure**:
  ```bash
  make
  ```
- **Stop containers and remove Compose volumes**:
  ```bash
  make clean
  ```
- **Full reset (prune Docker resources and wipe persistent data directories)**:
  ```bash
  make fclean
  ```
- **Rebuild and restart from scratch**:
  ```bash
  make re
  ```

---

## Resources

### Documentation & References
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Specification](https://docs.docker.com/compose/)
- [NGINX Official Documentation](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [WordPress Developer Resources & WP-CLI](https://developer.wordpress.org/cli/commands/)
- [Debian Bookworm Documentation](https://www.debian.org/releases/bookworm/)

### AI Usage Declaration
AI was used during this project for the following tasks:
- **Debugging & Troubleshooting**: Diagnosing timing conditions between MariaDB and WordPress during initial volume bootstrap, as well as Unix socket connection behavior in Debian Bookworm.
- **Base Image Migration**: Assisting in upgrading base images from Debian Bullseye to Debian Bookworm (migrating PHP 7.4 configurations to PHP 8.2).
- **Refactoring & Code Quality**: Streamlining Dockerfiles, configuration files, and shell entrypoint scripts into a clean, maintainable structure without boilerplate.
- **Documentation**: Assisting in structuring and writing `README.md`, `USER_DOC.md`, and `DEV_DOC.md` in accordance with 42 curriculum requirements.