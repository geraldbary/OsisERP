# OsisERP Deployment Scripts

Automated deployment scripts for OsisERP - Enterprise Resource Planning System based on OCA/OCB 18.0.

## Quick Install

Run this command on a fresh Ubuntu 20.04+ or Debian 11+ server:

```bash
curl -sSL https://raw.githubusercontent.com/geraldbary/OsisERP/main/scripts/osiserp-deploy.sh | sudo bash
```

Or download and run manually:

```bash
wget https://raw.githubusercontent.com/geraldbary/OsisERP/main/scripts/osiserp-deploy.sh
chmod +x osiserp-deploy.sh
sudo ./osiserp-deploy.sh
```

## Features

### Interactive Installation

The script provides an interactive installation experience:

1. **System Analysis** - Automatically detects CPU, RAM, disk space
2. **User Scale Selection** - Optimizes for small/medium/large/enterprise deployments
3. **Module Selection** - Choose which OCA module packages to install
4. **Domain Configuration** - Optional domain and SSL setup
5. **Performance Optimization** - Auto-calculates optimal Odoo and PostgreSQL settings

### Module Packages

| Package | Description | OCA Repositories |
|---------|-------------|------------------|
| **CORE** (Always) | Server tools, Web UX, Security | server-tools, server-ux, web, reporting-engine |
| **ACCOUNTING** | Financial management | account-financial-tools, account-payment, mis-builder |
| **HR & PAYROLL** | Human resources | hr, payroll, hr-attendance |
| **MANUFACTURING** | Production/MRP | manufacture, manufacture-reporting |
| **INVENTORY** | Warehouse management | stock-logistics-warehouse, stock-logistics-workflow |
| **SALES & CRM** | Sales and CRM | sale-workflow, crm, partner-contact |
| **PURCHASE** | Procurement | purchase-workflow |
| **PROJECT** | Project management | project, timesheet |
| **SYSCOHADA** | OHADA accounting (Africa) | Custom OsisERP module |

### Performance Scaling

| Scale | Users | Workers | Memory | DB Connections |
|-------|-------|---------|--------|----------------|
| Small | 1-10 | 2 | 512MB-1GB | 32 |
| Medium | 10-50 | 4 | 1GB-2GB | 64 |
| Large | 50-200 | 8 | 2GB-4GB | 128 |
| Enterprise | 200+ | CPU×2 | 3GB-6GB | 256 |

## Management Commands

After installation, use the `osiserp` command:

```bash
# Service management
osiserp start          # Start all services
osiserp stop           # Stop all services
osiserp restart        # Restart all services
osiserp status         # Show service status

# Logs and debugging
osiserp logs           # View Odoo logs
osiserp logs db        # View PostgreSQL logs
osiserp shell          # Open Odoo container shell
osiserp dbshell        # Open PostgreSQL shell

# Module management
osiserp install-module <name>  # Install a module
osiserp update-module <name>   # Update a module

# Maintenance
osiserp backup         # Run manual backup
osiserp update         # Update OsisERP from GitHub
osiserp credentials    # Show saved credentials
```

## Directory Structure

```
/opt/osiserp/              # Installation directory
├── docker-compose.yml     # Docker configuration
├── Dockerfile             # Odoo image definition
├── odoo.conf              # Odoo configuration
├── entrypoint.sh          # Container entrypoint
└── custom/addons/         # Custom modules
    ├── osiserp_oca/       # OCA modules
    ├── osiserp_themes/    # Theme modules
    └── osiserp_core/      # Core modules

/var/lib/osiserp/          # Data directory
├── odoo-data/             # Odoo filestore
└── postgres-data/         # PostgreSQL data

/var/log/osiserp/          # Log files
/var/backups/osiserp/      # Automated backups
/root/.osiserp_credentials # Saved credentials
```

## Security Features

- **UFW Firewall** - Only SSH, HTTP, HTTPS allowed
- **Fail2Ban** - Brute force protection
- **Let's Encrypt SSL** - Free HTTPS certificates
- **Secure Passwords** - Auto-generated strong passwords
- **Database Isolation** - PostgreSQL only accessible locally

## Backup System

Automated daily backups at 2 AM:
- Database dump (compressed)
- Filestore archive
- 7-day retention

Manual backup: `osiserp backup`

## Requirements

- **OS**: Ubuntu 20.04+ or Debian 11+
- **RAM**: Minimum 2GB (4GB+ recommended)
- **Disk**: Minimum 20GB free space
- **Network**: Public IP or domain name

## Troubleshooting

### Check service status
```bash
osiserp status
docker ps
```

### View logs
```bash
osiserp logs
tail -f /var/log/osiserp/odoo-server.log
```

### Restart services
```bash
osiserp restart
```

### Check Nginx
```bash
nginx -t
systemctl status nginx
```

### Check Docker
```bash
docker-compose -f /opt/osiserp/docker-compose.yml ps
docker-compose -f /opt/osiserp/docker-compose.yml logs
```

## Uninstall

```bash
# Stop services
osiserp stop

# Remove containers and images
cd /opt/osiserp
docker-compose down -v --rmi all

# Remove files (CAUTION: This deletes all data!)
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

## Support

- **Website**: https://globalosis.com
- **GitHub**: https://github.com/geraldbary/OsisERP
- **Author**: OSIS (Open System & Innovation Solution)

## License

LGPL-3.0 - See LICENSE file for details.
