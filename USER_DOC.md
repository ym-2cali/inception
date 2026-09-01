# User Documentation

This guide provides end users and evaluators with straightforward instructions on how to use and manage the Inception web stack on a Linux Mint Virtual Machine.

---

## 1. Services Provided by the Stack

The infrastructure runs three containerized services on Debian Bookworm:

| Service | Container Name | Protocol & Port | Description |
|---|---|---|---|
| **NGINX** | `nginx` | HTTPS (`443`) | The single external entry point secured with TLSv1.2/TLSv1.3. Serves static files and proxies PHP requests to WordPress. |
| **WordPress** | `wordpress` | FastCGI (`9000` internal) | Runs WordPress on PHP-FPM 8.2 to process web requests. |
| **MariaDB** | `mariadb` | MySQL (`3306` internal) | Stores database tables, user accounts, and site content. |

---

## 2. Starting and Stopping the Project

Run all commands from the repository root directory on your Linux Mint VM:

- **Start everything** (builds images and starts containers):
  ```bash
  make
  ```
- **Stop the project** (shuts down containers and temporary volumes):
  ```bash
  make clean
  ```
- **Full reset** (stops containers, cleans Docker objects, and removes all persistent data on the host):
  ```bash
  make fclean
  ```
- **Rebuild and restart from scratch**:
  ```bash
  make re
  ```

---

## 3. Accessing the Website and Administration Panel

### Step 1: Configure Local Hostname (First Time Only)
On the Linux Mint VM, add `yael-maa.42.fr` to `/etc/hosts`:
```bash
echo "127.0.0.1 yael-maa.42.fr" | sudo tee -a /etc/hosts
```

### Step 2: Open in Web Browser
Open Firefox or your preferred browser inside the Linux Mint VM:
- **Public Website**: [https://yael-maa.42.fr](https://yael-maa.42.fr)
- **WordPress Admin Dashboard**: [https://yael-maa.42.fr/wp-admin](https://yael-maa.42.fr/wp-admin) (or [https://yael-maa.42.fr/wp-login.php](https://yael-maa.42.fr/wp-login.php))

*(Note: Because self-signed SSL certificates are used, accept the browser security warning by clicking "Advanced" -> "Accept the Risk and Continue").*

---

## 4. Locating and Managing Credentials

All user accounts and database credentials are stored in the environment configuration file:
```
srcs/.env
```

### Default Credentials
- **WordPress Administrator**:
  - Username: `${WP_ADMIN}` (`yael-maa`)
  - Password: `${WP_ADMIN_PASS}` (`admin_pass123`)
  - Email: `${WP_ADMIN_EMAIL}` (`yael-maa@student.42.fr`)
- **WordPress Author User**:
  - Username: `${WP_AUTHOR}` (`author`)
  - Password: `${WP_AUTHOR_PASS}` (`author_pass123`)
  - Email: `${WP_AUTHOR_EMAIL}` (`author@student.42.fr`)
- **MariaDB Root Password**: `${MYSQL_ROOT_PASSWORD}` (`root_pass123`)
- **MariaDB Database User**:
  - Database: `${MYSQL_DATABASE}` (`wordpress_db`)
  - Username: `${MYSQL_USER}` (`wp_user`)
  - Password: `${MYSQL_PASSWORD}` (`wp_pass123`)

---

## 5. Checking Service Health and Logs

Verify that services are functioning as expected using standard Docker commands:

### Check Container Status
```bash
docker compose -f srcs/docker-compose.yml ps
```
All containers (`nginx`, `wordpress`, `mariadb`) should have the status `Up`.

### View Live Logs
```bash
# View combined logs
docker compose -f srcs/docker-compose.yml logs -f

# Or check a specific container
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Test HTTPS Endpoint from Terminal
```bash
curl -k https://yael-maa.42.fr
```