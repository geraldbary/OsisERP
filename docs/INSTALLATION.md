# OsisERP Installation Guide

## Prerequisites

### Supported Operating Systems
- Ubuntu 20.04 LTS or later
- Debian 11 (Bullseye) or later

### Minimum Requirements
| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2 GB | 4+ GB |
| CPU | 1 core | 2+ cores |
| Disk | 20 GB | 50+ GB |
| Network | Public IP | Domain + SSL |

---

## Quick Installation

### One-Line Install

```bash
curl -sSL https://raw.githubusercontent.com/geraldbary/OsisERP/main/scripts/osiserp-deploy.sh | sudo bash
```

### Manual Download

```bash
# Download the script
wget https://raw.githubusercontent.com/geraldbary/OsisERP/main/scripts/osiserp-deploy.sh

# Make it executable
chmod +x osiserp-deploy.sh

# Run with sudo
sudo ./osiserp-deploy.sh
```

---

## Interactive Installation Process

The installer will guide you through these steps:

### 1. System Analysis

The script automatically detects:
- CPU cores and model
- Total RAM
- Available disk space
- Public IP address
- Operating system version

### 2. User Scale Selection

Choose based on expected concurrent users:

| Option | Users | Description |
|--------|-------|-------------|
| Small | 1-10 | Minimal resources, suitable for testing |
| Medium | 10-50 | Balanced for small businesses |
| Large | 50-200 | High performance for growing companies |
| Enterprise | 200+ | Maximum performance, multi-worker |

### 3. Module Package Selection

Select which OCA module packages to install:

```
✓ CORE (Always Installed)
    Server Tools, Web UX, Security, Audit, Backup

1) ACCOUNTING - Financial Reports, Assets, Fiscal Year
2) HR & PAYROLL - Employee Management, Payroll, Contracts
3) MANUFACTURING - MRP, BOM, Production Planning
4) INVENTORY - Warehouse, Stock, Logistics
5) SALES & CRM - Sales, CRM, Marketing
6) PURCHASE - Purchase Management, Vendor Portal
7) PROJECT - Project Management, Timesheet
8) SYSCOHADA - OHADA Accounting (Africa)
9) ALL PACKAGES - Install everything
0) CORE ONLY - Minimal installation
```

### 4. Domain Configuration

- Enter your domain name (e.g., `erp.yourcompany.com`)
- Or press Enter for IP-only access
- Option to setup Let's Encrypt SSL automatically

### 5. Database Configuration

- Database name (default: `osiserp`)
- Database user (default: `odoo`)
- Secure passwords are auto-generated

---

## What Gets Installed

### System Packages
- Docker & Docker Compose
- Nginx web server
- Certbot (SSL certificates)
- UFW firewall
- Fail2Ban (brute force protection)
- Git, curl, wget, htop

### Docker Containers
- **osiserp-odoo** - Odoo application server
- **osiserp-db** - PostgreSQL 16 database

### OCA Modules (based on selection)
- Server tools and utilities
- Web UI enhancements
- Financial reporting
- HR and payroll
- Manufacturing/MRP
- Inventory management
- And more...

---

## Post-Installation

### Access OsisERP

After installation completes:

1. **With Domain + SSL:**
   ```
   https://your-domain.com
   ```

2. **With IP only:**
   ```
   http://YOUR_SERVER_IP
   ```

### Default Credentials

Credentials are displayed at the end of installation and saved to:
```
/root/.osiserp_credentials
```

View them anytime:
```bash
osiserp credentials
```

### Create Your First Database

1. Access the Odoo interface
2. Enter the **Master Password** (admin password from credentials)
3. Fill in database details:
   - Database Name: `your_company`
   - Email: `admin@yourcompany.com`
   - Password: Choose a strong password
   - Language: Select your language
   - Country: Select your country
4. Click **Create Database**

---

## Management Commands

```bash
# Start/Stop/Restart
osiserp start
osiserp stop
osiserp restart

# Check status
osiserp status

# View logs
osiserp logs          # Odoo logs
osiserp logs db       # PostgreSQL logs

# Backup
osiserp backup

# Update from GitHub
osiserp update

# Module management
osiserp install-module <module_name>
osiserp update-module <module_name>

# Shell access
osiserp shell         # Odoo container
osiserp dbshell       # PostgreSQL
```

---

## Directory Structure

```
/opt/osiserp/              # Installation directory
├── docker-compose.yml     # Docker configuration
├── Dockerfile             # Odoo image
├── odoo.conf              # Odoo configuration
├── entrypoint.sh          # Container startup
└── custom/addons/         # Custom modules

/var/lib/osiserp/          # Data (persistent)
├── odoo-data/             # Filestore
└── postgres-data/         # Database

/var/log/osiserp/          # Logs
/var/backups/osiserp/      # Backups
/root/.osiserp_credentials # Credentials
```

---

## Troubleshooting

### Services not starting

```bash
# Check Docker status
systemctl status docker

# Check container status
docker ps -a

# View logs
osiserp logs
```

### Cannot access web interface

```bash
# Check Nginx
nginx -t
systemctl status nginx

# Check firewall
ufw status
```

### Database connection issues

```bash
# Check PostgreSQL container
docker logs osiserp-db

# Test connection
docker exec osiserp-db pg_isready -U odoo
```

### SSL certificate issues

```bash
# Renew certificate
certbot renew

# Check certificate
certbot certificates
```

---

## Upgrading

### Update OsisERP

```bash
osiserp update
```

This will:
1. Pull latest changes from GitHub
2. Rebuild Docker image
3. Restart services

### Update specific module

```bash
osiserp update-module module_name
```

---

## Uninstallation

⚠️ **Warning:** This will delete all data!

```bash
# Stop services
osiserp stop

# Remove everything
cd /opt/osiserp
docker-compose down -v --rmi all

# Delete files
rm -rf /opt/osiserp
rm -rf /var/lib/osiserp
rm -rf /var/log/osiserp
rm -rf /var/backups/osiserp
rm /etc/nginx/sites-enabled/osiserp
rm /etc/nginx/sites-available/osiserp
rm /etc/systemd/system/osiserp.service
rm /usr/local/bin/osiserp
rm /usr/local/bin/osiserp-backup
rm /root/.osiserp_credentials

# Reload services
systemctl daemon-reload
systemctl reload nginx
```

---

## Support

- **Website:** https://globalosis.com
- **GitHub Issues:** https://github.com/geraldbary/OsisERP/issues
- **Email:** support@globalosis.com
