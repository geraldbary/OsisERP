# OsisERP

<p align="center">
  <img src="docs/images/osiserp-logo.png" alt="OsisERP Logo" width="200"/>
</p>

<p align="center">
  <strong>Enterprise Resource Planning System</strong><br>
  Based on OCA/OCB 18.0 - 100% Open Source
</p>

<p align="center">
  <a href="#quick-install">Quick Install</a> •
  <a href="#features">Features</a> •
  <a href="#modules">Modules</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#support">Support</a>
</p>

---

## Quick Install

Deploy OsisERP on a fresh Ubuntu/Debian server with one command:

```bash
curl -sSL https://raw.githubusercontent.com/geraldbary/OsisERP/main/scripts/osiserp-deploy.sh | sudo bash
```

The interactive installer will:
- Analyze your server resources
- Ask about expected user count
- Let you select module packages
- Configure domain and SSL
- Optimize performance automatically

## Features

### Core Platform
- **OCA/OCB 18.0** - Odoo Community Backports
- **Docker-based** - Easy deployment and scaling
- **PostgreSQL 16** - Latest database features
- **Nginx** - Reverse proxy with caching
- **Auto SSL** - Let's Encrypt integration

### Business Modules
- **Accounting** - Full financial management with MIS reports
- **HR & Payroll** - Employee management and payroll
- **Manufacturing** - MRP, BOM, production planning
- **Inventory** - Warehouse and logistics
- **Sales & CRM** - Customer relationship management
- **Purchase** - Procurement and vendor management
- **Project** - Project and timesheet management

### Regional Compliance
- **SYSCOHADA** - OHADA accounting for Africa
- Multi-currency support
- Localized chart of accounts

### Enterprise Theme
- Modern dark navbar
- Animated home menu
- Responsive design
- Custom branding

## Modules

### Custom OsisERP Modules

| Module | Description |
|--------|-------------|
| `os_web_theme` | Enterprise-style theme with custom branding |
| `osiserp_syscohada_reports` | OHADA-compliant financial reports |

### Included OCA Repositories

| Category | Repositories |
|----------|--------------|
| **Core** | server-tools, server-ux, web, reporting-engine |
| **Accounting** | account-financial-tools, account-payment, mis-builder |
| **HR** | hr, payroll, hr-attendance |
| **Manufacturing** | manufacture, manufacture-reporting |
| **Inventory** | stock-logistics-warehouse, stock-logistics-workflow |
| **Sales** | sale-workflow, crm, partner-contact |
| **Purchase** | purchase-workflow |
| **Project** | project, timesheet |

## Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Module Reference](docs/MODULES.md)
- [Configuration Guide](docs/CONFIGURATION.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## Repository Structure

```
OsisERP/
├── scripts/
│   ├── osiserp-deploy.sh      # Main deployment script
│   └── README.md              # Script documentation
├── modules/
│   ├── osiserp_themes/        # Theme modules
│   │   └── os_web_theme/      # Custom OsisERP theme
│   ├── osiserp_syscohada_reports/  # SYSCOHADA reports
│   └── osiserp_core/          # Core functionality
├── config/
│   ├── odoo.conf.template     # Odoo config template
│   ├── nginx.conf.template    # Nginx config template
│   └── docker-compose.yml.template
├── docs/
│   ├── INSTALLATION.md
│   ├── MODULES.md
│   └── images/
└── README.md
```

## Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **OS** | Ubuntu 20.04 / Debian 11 | Ubuntu 22.04 / Debian 12 |
| **RAM** | 2 GB | 4+ GB |
| **CPU** | 1 core | 2+ cores |
| **Disk** | 20 GB | 50+ GB |

## Management

After installation, use the `osiserp` command:

```bash
osiserp start          # Start services
osiserp stop           # Stop services
osiserp restart        # Restart services
osiserp status         # Check status
osiserp logs           # View logs
osiserp backup         # Run backup
osiserp update         # Update from GitHub
```

## Support

- **Website**: [globalosis.com](https://globalosis.com)
- **Issues**: [GitHub Issues](https://github.com/geraldbary/OsisERP/issues)
- **Email**: support@globalosis.com

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under LGPL-3.0 - see the [LICENSE](LICENSE) file for details.

## Credits

- **OCA** - Odoo Community Association
- **Odoo SA** - Original Odoo software
- **OSIS** - Open System & Innovation Solution

---

<p align="center">
  Made with ❤️ by <a href="https://globalosis.com">OSIS</a>
</p>
