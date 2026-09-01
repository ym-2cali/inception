# Developer Documentation

This document describes the technical architecture, development workflow, and management commands for the Inception project deployed on a Linux Mint Virtual Machine.

---

## 1. Environment Setup from Scratch

### Prerequisites on Linux Mint VM
Install the required tools:
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2 make curl
```

Ensure non-root Docker usage by adding your user to the `docker` group:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

Start and enable Docker:
```bash
sudo service docker start
```

### Local DNS Setup
Map the domain name `yael-maa.42.fr` to the local loopback address:
```bash
echo "127.0.0.1 yael-maa.42.fr" | sudo tee -a /etc/hosts
```

### Environment Configuration
The environment file `srcs/.env` is read by Docker Compose:
```env
MYSQL_HOST=mariadb
MYSQL_DATABASE=wordpress_db
MYSQL_USER=wp_user
MYSQL_PASSWORD=wp_pass123
MYSQL_ROOT_PASSWORD=root_pass123

WP_URL=yael-maa.42.fr
SITE_TITLE=Inception

WP_ADMIN=yael-maa
WP_ADMIN_PASS=admin_pass123
WP_ADMIN_EMAIL=yael-maa@student.42.fr

WP_AUTHOR=author
WP_AUTHOR_PASS=author_pass123
WP_AUTHOR_EMAIL=author@student.42.fr
```

---

## 2. Technical Architecture & File Structure

```
inception/
+-- Makefile
+-- README.md
+-- USER_DOC.md
+-- DEV_DOC.md
+-- srcs/
    +-- .env
    +-- docker-compose.yml
    +-- requirements/
        +-- mariadb/
        ¦   +-- Dockerfile
        ¦   +-- conf/
        ¦   ¦   +-- 50-server.cnf
        ¦   +-- tools/
        ¦       +-- script.sh
        +-- nginx/
        ¦   +-- Dockerfile
        ¦   +-- conf/
        ¦       +-- config.conf
        +-- wordpress/
            +-- Dockerfile
            +-- tools/
                +-- wordpress.sh
```

### Component Details
- **`nginx`** (`srcs/requirements/nginx`):
  - Base image: `debian:bookworm`
  - Generates self-signed TLS certificates for `yael-maa.42.fr`.
  - Configures TLSv1.2 and TLSv1.3 protocols on port 443.
  - Proxies PHP requests to `wordpress:9000` via FastCGI.
- **`mariadb`** (`srcs/requirements/mariadb`):
  - Base image: `debian:bookworm`
  - Installs MariaDB Server.
  - `50-server.cnf` binds to `0.0.0.0` on port `3306` with Unix socket support.
  - `script.sh` bootstraps database tables, sets credentials, and executes `mariadbd`.
- **`wordpress`** (`srcs/requirements/wordpress`):
  - Base image: `debian:bookworm`
  - Installs PHP 8.2, PHP-FPM, PHP-MySQL, and `mariadb-client`.
  - `wordpress.sh` configures PHP-FPM socket on port 9000, downloads WP-CLI, waits for MariaDB readiness, and provisions WordPress users.

---

## 3. Build & Launch Workflow

### Using the Makefile
- **Build and start services**:
  ```bash
  make
  ```
- **Stop containers and remove Compose volumes**:
  ```bash
  make clean
  ```
- **Prune Docker objects and wipe persistent storage directories**:
  ```bash
  make fclean
  ```
- **Clean and rebuild from scratch**:
  ```bash
  make re
  ```

### Direct Docker Compose Commands
- **Build images without cache**:
  ```bash
  docker compose -f srcs/docker-compose.yml build --no-cache
  ```
- **Run in detached mode**:
  ```bash
  docker compose -f srcs/docker-compose.yml up -d
  ```
- **Stop containers**:
  ```bash
  docker compose -f srcs/docker-compose.yml down
  ```

---

## 4. Container & Volume Management

### Inspecting Running Containers
```bash
# List all running containers in the stack
docker compose -f srcs/docker-compose.yml ps

# View live container resource consumption
docker stats

# Open an interactive shell inside a container
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash
```

### Inspecting Networks
All containers join the user-defined bridge network `srcs_inception`:
```bash
docker network inspect srcs_inception
```

---

## 5. Data Storage & Persistence

The project stores persistent application data on the host machine using bind mounts configured in `srcs/docker-compose.yml`:

| Volume Name | Host Path | Container Target | Purpose |
|---|---|---|---|
| `db_data` | `/home/yael-maa/data/mariadb` | `/var/lib/mysql` | MariaDB tables, schemas, and user data. |
| `wp_data` | `/home/yael-maa/data/wordpress` | `/var/www/html` | WordPress core files, themes, plugins, and uploads. |

### Persistence Mechanism
1. **Creation**: Before starting the containers, the Makefile creates the host directories (`mkdir -p /home/yael-maa/data/mariadb /home/yael-maa/data/wordpress`).
2. **Mounting**: Docker Compose binds these host paths to container directories with `type: none` and `o: bind`.
3. **Data Lifecycle**:
   - Restarting containers (`docker compose down && docker compose up`) retains all database records and WordPress posts.
   - Running `make fclean` explicitly wipes these folders (`rm -rf /home/yael-maa/data/mariadb/* /home/yael-maa/data/wordpress/*`), resetting the stack to a clean slate.