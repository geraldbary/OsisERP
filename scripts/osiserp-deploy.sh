#!/bin/bash
#===============================================================================
#
#          FILE: osiserp-deploy.sh
#
#         USAGE: curl -sSL https://raw.githubusercontent.com/geraldbary/OsisERP/main/scripts/osiserp-deploy.sh | sudo bash -s -- --auto
#                or: ./osiserp-deploy.sh [OPTIONS]
#
#   DESCRIPTION: OsisERP Automated Deployment Script
#                Deploys OCA/OCB 18.0 based ERP with custom modules
#
#       OPTIONS: --auto        Auto-accept defaults (for non-interactive install)
#                --help        Show help message
#                --uninstall   Remove OsisERP
#                --update      Update existing installation
#  REQUIREMENTS: Ubuntu 20.04+ / Debian 11+
#        AUTHOR: OSIS (Open System & Innovation Solution)
#       WEBSITE: https://globalosis.com
#       VERSION: 1.0.0
#       CREATED: December 2024
#
#===============================================================================

set -e

#===============================================================================
# COMMAND LINE ARGUMENTS
#===============================================================================
AUTO_MODE=false
SHOW_HELP=false
DO_UNINSTALL=false
DO_UPDATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --auto|-y|--yes)
            AUTO_MODE=true
            shift
            ;;
        --help|-h)
            SHOW_HELP=true
            shift
            ;;
        --uninstall)
            DO_UNINSTALL=true
            shift
            ;;
        --update)
            DO_UPDATE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Detect if running non-interactively (piped)
if [[ ! -t 0 ]]; then
    AUTO_MODE=true
fi

#===============================================================================
# CONFIGURATION
#===============================================================================
OSISERP_VERSION="18.0"
GITHUB_REPO="https://github.com/geraldbary/OsisERP.git"
GITHUB_BRANCH="main"
INSTALL_DIR="/opt/osiserp"
DATA_DIR="/var/lib/osiserp"
LOG_DIR="/var/log/osiserp"
BACKUP_DIR="/var/backups/osiserp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Module packages
declare -A MODULE_PACKAGES

#===============================================================================
# HELPER FUNCTIONS
#===============================================================================

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
   ____       _     _____ ____  ____  
  / __ \___  (_)___/ ____|  _ \|  _ \ 
 | |  | / __|/ / __|  _| | |_) | |_) |
 | |__| \__ \ \__ \ |___|  _ <|  __/ 
  \____/|___/_|___/_____|_| \_\_|    
                                      
  Enterprise Resource Planning System
  Based on OCA/OCB 18.0
EOF
    echo -e "${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  Version: ${OSISERP_VERSION} | By: OSIS (globalosis.com)${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${PURPLE}▶${NC} ${WHITE}$1${NC}"
}

confirm() {
    if [[ "$AUTO_MODE" == true ]]; then
        log_info "Auto-accepting: $1"
        return 0
    fi
    read -p "$(echo -e ${YELLOW}"$1 [y/N]: "${NC})" response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        log_error "Cannot detect OS. This script requires Ubuntu 20.04+ or Debian 11+"
        exit 1
    fi
    
    case $OS in
        ubuntu)
            if [[ "${VERSION%%.*}" -lt 20 ]]; then
                log_error "Ubuntu 20.04 or higher is required"
                exit 1
            fi
            ;;
        debian)
            if [[ "${VERSION%%.*}" -lt 11 ]]; then
                log_error "Debian 11 or higher is required"
                exit 1
            fi
            ;;
        *)
            log_error "Unsupported OS: $OS. Use Ubuntu 20.04+ or Debian 11+"
            exit 1
            ;;
    esac
    
    log_success "Detected: $PRETTY_NAME"
}

#===============================================================================
# SYSTEM ANALYSIS
#===============================================================================

analyze_system() {
    log_step "Analyzing System Resources..."
    
    # CPU
    CPU_CORES=$(nproc)
    CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
    
    # Memory
    TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_RAM_GB=$((TOTAL_RAM_KB / 1024 / 1024))
    TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
    
    # Disk
    DISK_TOTAL=$(df -BG / | tail -1 | awk '{print $2}' | tr -d 'G')
    DISK_AVAIL=$(df -BG / | tail -1 | awk '{print $4}' | tr -d 'G')
    
    # Network
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    
    echo ""
    echo -e "${WHITE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│${NC}              ${CYAN}SYSTEM SPECIFICATIONS${NC}                      ${WHITE}│${NC}"
    echo -e "${WHITE}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│${NC} CPU:        ${GREEN}$CPU_CORES cores${NC} - $CPU_MODEL"
    echo -e "${WHITE}│${NC} RAM:        ${GREEN}${TOTAL_RAM_GB} GB${NC} (${TOTAL_RAM_MB} MB)"
    echo -e "${WHITE}│${NC} Disk:       ${GREEN}${DISK_AVAIL} GB${NC} available of ${DISK_TOTAL} GB"
    echo -e "${WHITE}│${NC} Public IP:  ${GREEN}$PUBLIC_IP${NC}"
    echo -e "${WHITE}│${NC} OS:         ${GREEN}$PRETTY_NAME${NC}"
    echo -e "${WHITE}└─────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

#===============================================================================
# USER CONFIGURATION
#===============================================================================

get_user_count() {
    log_step "Performance Configuration"
    
    if [[ "$AUTO_MODE" == true ]]; then
        # Auto-detect based on RAM
        if [[ $TOTAL_RAM_GB -ge 8 ]]; then
            USER_SCALE="large"
        elif [[ $TOTAL_RAM_GB -ge 4 ]]; then
            USER_SCALE="medium"
        else
            USER_SCALE="small"
        fi
        log_info "Auto-selected: $USER_SCALE scale (based on ${TOTAL_RAM_GB}GB RAM)"
        return
    fi
    
    echo ""
    echo -e "${WHITE}How many concurrent users will use OsisERP?${NC}"
    echo -e "  ${CYAN}1)${NC} Small    (1-10 users)     - Minimal resources"
    echo -e "  ${CYAN}2)${NC} Medium   (10-50 users)    - Balanced performance"
    echo -e "  ${CYAN}3)${NC} Large    (50-200 users)   - High performance"
    echo -e "  ${CYAN}4)${NC} Enterprise (200+ users)   - Maximum performance"
    echo ""
    read -p "$(echo -e ${YELLOW}"Select option [1-4]: "${NC})" user_choice
    
    case $user_choice in
        1) USER_SCALE="small" ;;
        2) USER_SCALE="medium" ;;
        3) USER_SCALE="large" ;;
        4) USER_SCALE="enterprise" ;;
        *) USER_SCALE="medium" ;;
    esac
    
    log_info "Selected: $USER_SCALE scale deployment"
}

calculate_performance_settings() {
    log_step "Calculating Optimal Performance Settings..."
    
    # Base calculations on RAM and CPU
    case $USER_SCALE in
        small)
            WORKERS=2
            MAX_CRON=1
            DB_MAXCONN=32
            LIMIT_MEM_SOFT=$((512 * 1024 * 1024))      # 512MB
            LIMIT_MEM_HARD=$((1024 * 1024 * 1024))     # 1GB
            PG_SHARED_BUFFERS="128MB"
            PG_WORK_MEM="4MB"
            PG_MAINTENANCE_WORK_MEM="64MB"
            PG_EFFECTIVE_CACHE="256MB"
            ;;
        medium)
            WORKERS=4
            MAX_CRON=2
            DB_MAXCONN=64
            LIMIT_MEM_SOFT=$((1024 * 1024 * 1024))     # 1GB
            LIMIT_MEM_HARD=$((2048 * 1024 * 1024))     # 2GB
            PG_SHARED_BUFFERS="256MB"
            PG_WORK_MEM="8MB"
            PG_MAINTENANCE_WORK_MEM="128MB"
            PG_EFFECTIVE_CACHE="512MB"
            ;;
        large)
            WORKERS=8
            MAX_CRON=2
            DB_MAXCONN=128
            LIMIT_MEM_SOFT=$((2048 * 1024 * 1024))     # 2GB
            LIMIT_MEM_HARD=$((4096 * 1024 * 1024))     # 4GB
            PG_SHARED_BUFFERS="512MB"
            PG_WORK_MEM="16MB"
            PG_MAINTENANCE_WORK_MEM="256MB"
            PG_EFFECTIVE_CACHE="1GB"
            ;;
        enterprise)
            WORKERS=$((CPU_CORES * 2))
            MAX_CRON=4
            DB_MAXCONN=256
            LIMIT_MEM_SOFT=$((3072 * 1024 * 1024))     # 3GB
            LIMIT_MEM_HARD=$((6144 * 1024 * 1024))     # 6GB
            PG_SHARED_BUFFERS="1GB"
            PG_WORK_MEM="32MB"
            PG_MAINTENANCE_WORK_MEM="512MB"
            PG_EFFECTIVE_CACHE="2GB"
            ;;
    esac
    
    # Adjust based on actual available RAM
    if [[ $TOTAL_RAM_GB -lt 2 ]]; then
        WORKERS=2
        MAX_CRON=1
        LIMIT_MEM_SOFT=$((256 * 1024 * 1024))
        LIMIT_MEM_HARD=$((512 * 1024 * 1024))
        log_warning "Limited RAM detected. Reducing worker count."
    fi
    
    # Adjust workers based on CPU cores
    if [[ $WORKERS -gt $((CPU_CORES * 2)) ]]; then
        WORKERS=$((CPU_CORES * 2))
    fi
    
    echo ""
    echo -e "${WHITE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│${NC}           ${CYAN}CALCULATED PERFORMANCE SETTINGS${NC}              ${WHITE}│${NC}"
    echo -e "${WHITE}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│${NC} Odoo Workers:       ${GREEN}$WORKERS${NC}"
    echo -e "${WHITE}│${NC} Cron Threads:       ${GREEN}$MAX_CRON${NC}"
    echo -e "${WHITE}│${NC} DB Connections:     ${GREEN}$DB_MAXCONN${NC}"
    echo -e "${WHITE}│${NC} Memory Soft Limit:  ${GREEN}$((LIMIT_MEM_SOFT / 1024 / 1024)) MB${NC}"
    echo -e "${WHITE}│${NC} Memory Hard Limit:  ${GREEN}$((LIMIT_MEM_HARD / 1024 / 1024)) MB${NC}"
    echo -e "${WHITE}│${NC} PG Shared Buffers:  ${GREEN}$PG_SHARED_BUFFERS${NC}"
    echo -e "${WHITE}└─────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

#===============================================================================
# MODULE SELECTION
#===============================================================================

select_modules() {
    log_step "Module Package Selection"
    
    # Initialize arrays
    SELECTED_PACKAGES=("core")
    
    if [[ "$AUTO_MODE" == true ]]; then
        # In auto mode, install all packages
        SELECTED_PACKAGES=("core" "accounting" "hr_payroll" "manufacturing" "inventory" "sales_crm" "purchase" "project" "syscohada")
        log_info "Auto-mode: Installing ALL packages"
        log_info "Selected packages: ${SELECTED_PACKAGES[*]}"
        return
    fi
    
    echo ""
    echo -e "${WHITE}Select the OCA module packages to install:${NC}"
    echo -e "${CYAN}(Core modules are always installed)${NC}"
    echo ""
    
    # Core (always installed)
    echo -e "  ${GREEN}✓${NC} ${WHITE}CORE${NC} (Always Installed)"
    echo -e "      Server Tools, Web UX, Security, Audit, Backup"
    echo ""
    
    # Optional packages
    echo -e "  ${CYAN}1)${NC} ${WHITE}ACCOUNTING${NC} - Financial Reports, Assets, Fiscal Year"
    echo -e "  ${CYAN}2)${NC} ${WHITE}HR & PAYROLL${NC} - Employee Management, Payroll, Contracts"
    echo -e "  ${CYAN}3)${NC} ${WHITE}MANUFACTURING${NC} - MRP, BOM, Production Planning"
    echo -e "  ${CYAN}4)${NC} ${WHITE}INVENTORY${NC} - Warehouse, Stock, Logistics"
    echo -e "  ${CYAN}5)${NC} ${WHITE}SALES & CRM${NC} - Sales, CRM, Marketing"
    echo -e "  ${CYAN}6)${NC} ${WHITE}PURCHASE${NC} - Purchase Management, Vendor Portal"
    echo -e "  ${CYAN}7)${NC} ${WHITE}PROJECT${NC} - Project Management, Timesheet"
    echo -e "  ${CYAN}8)${NC} ${WHITE}SYSCOHADA${NC} - OHADA Accounting (Africa)"
    echo -e "  ${CYAN}9)${NC} ${WHITE}ALL PACKAGES${NC} - Install everything"
    echo ""
    echo -e "  ${CYAN}0)${NC} ${WHITE}CORE ONLY${NC} - Minimal installation"
    echo ""
    
    read -p "$(echo -e ${YELLOW}"Enter package numbers (comma-separated, e.g., 1,2,3): "${NC})" module_choices
    
    if [[ "$module_choices" == "9" ]]; then
        SELECTED_PACKAGES=("core" "accounting" "hr_payroll" "manufacturing" "inventory" "sales_crm" "purchase" "project" "syscohada")
    elif [[ "$module_choices" != "0" ]]; then
        IFS=',' read -ra choices <<< "$module_choices"
        for choice in "${choices[@]}"; do
            choice=$(echo "$choice" | xargs)  # trim whitespace
            case $choice in
                1) SELECTED_PACKAGES+=("accounting") ;;
                2) SELECTED_PACKAGES+=("hr_payroll") ;;
                3) SELECTED_PACKAGES+=("manufacturing") ;;
                4) SELECTED_PACKAGES+=("inventory") ;;
                5) SELECTED_PACKAGES+=("sales_crm") ;;
                6) SELECTED_PACKAGES+=("purchase") ;;
                7) SELECTED_PACKAGES+=("project") ;;
                8) SELECTED_PACKAGES+=("syscohada") ;;
            esac
        done
    fi
    
    echo ""
    log_info "Selected packages: ${SELECTED_PACKAGES[*]}"
}

#===============================================================================
# DOMAIN & SSL CONFIGURATION
#===============================================================================

configure_domain() {
    log_step "Domain Configuration"
    
    if [[ "$AUTO_MODE" == true ]]; then
        # In auto mode, use IP-only access
        DOMAIN_NAME="_"
        USE_SSL=false
        log_info "Auto-mode: Using IP-only access (no domain)"
        log_info "Domain: $DOMAIN_NAME | SSL: $USE_SSL"
        return
    fi
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter your domain name (or press Enter for IP-only access): "${NC})" DOMAIN_NAME
    
    if [[ -n "$DOMAIN_NAME" ]]; then
        USE_SSL=true
        read -p "$(echo -e ${YELLOW}"Setup Let's Encrypt SSL? [Y/n]: "${NC})" ssl_choice
        case "$ssl_choice" in
            [nN][oO]|[nN]) USE_SSL=false ;;
            *) USE_SSL=true ;;
        esac
    else
        DOMAIN_NAME="_"
        USE_SSL=false
    fi
    
    log_info "Domain: $DOMAIN_NAME | SSL: $USE_SSL"
}

#===============================================================================
# DATABASE CONFIGURATION
#===============================================================================

configure_database() {
    log_step "Database Configuration"
    
    # Generate random passwords
    DB_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
    ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
    
    if [[ "$AUTO_MODE" == true ]]; then
        # Use defaults in auto mode
        DB_NAME="osiserp"
        DB_USER="odoo"
        log_info "Auto-mode: Using default database settings"
        log_info "Database: $DB_NAME | User: $DB_USER"
        echo ""
        echo -e "${WHITE}Generated secure passwords:${NC}"
        echo -e "  Database Password: ${GREEN}$DB_PASSWORD${NC}"
        echo -e "  Odoo Admin Password: ${GREEN}$ADMIN_PASSWORD${NC}"
        echo ""
        log_warning "Credentials will be stored in /root/.osiserp_credentials"
        return
    fi
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Database name [osiserp]: "${NC})" DB_NAME
    DB_NAME=${DB_NAME:-osiserp}
    
    read -p "$(echo -e ${YELLOW}"Database user [odoo]: "${NC})" DB_USER
    DB_USER=${DB_USER:-odoo}
    
    echo ""
    echo -e "${WHITE}Generated secure passwords:${NC}"
    echo -e "  Database Password: ${GREEN}$DB_PASSWORD${NC}"
    echo -e "  Odoo Admin Password: ${GREEN}$ADMIN_PASSWORD${NC}"
    echo ""
    log_warning "Save these passwords securely! They will be stored in /root/.osiserp_credentials"
}

#===============================================================================
# INSTALLATION FUNCTIONS
#===============================================================================

install_dependencies() {
    log_step "Installing System Dependencies..."
    
    apt-get update -qq
    apt-get install -y -qq \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common \
        git \
        wget \
        unzip \
        htop \
        nano \
        ufw \
        fail2ban \
        certbot \
        python3-certbot-nginx \
        > /dev/null 2>&1
    
    log_success "System dependencies installed"
}

install_docker() {
    log_step "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        log_info "Docker already installed: $(docker --version)"
    else
        # Install Docker
        curl -fsSL https://get.docker.com | sh > /dev/null 2>&1
        
        # Install Docker Compose
        DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
        curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null 2>&1
        chmod +x /usr/local/bin/docker-compose
        
        # Start Docker
        systemctl enable docker
        systemctl start docker
        
        log_success "Docker installed: $(docker --version)"
    fi
}

install_nginx() {
    log_step "Installing Nginx..."
    
    apt-get install -y -qq nginx > /dev/null 2>&1
    systemctl enable nginx
    systemctl start nginx
    
    log_success "Nginx installed"
}

clone_repository() {
    log_step "Cloning OsisERP Repository..."
    
    if [[ -d "$INSTALL_DIR" ]]; then
        log_warning "Installation directory exists. Backing up..."
        mv "$INSTALL_DIR" "${INSTALL_DIR}.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    git clone --depth 1 --branch "$GITHUB_BRANCH" "$GITHUB_REPO" "$INSTALL_DIR" > /dev/null 2>&1
    
    log_success "Repository cloned to $INSTALL_DIR"
}

create_directories() {
    log_step "Creating Directory Structure..."
    
    mkdir -p "$DATA_DIR"/{odoo-data,postgres-data,redis-data}
    mkdir -p "$LOG_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$INSTALL_DIR/custom/addons"
    
    log_success "Directories created"
}

#===============================================================================
# CONFIGURATION FILE GENERATION
#===============================================================================

generate_odoo_config() {
    log_step "Generating Odoo Configuration..."
    
    cat > "$INSTALL_DIR/odoo.conf" << EOF
[options]
; Database settings
db_host = db
db_port = 5432
db_user = $DB_USER
db_password = $DB_PASSWORD
db_name = False
db_template = template0

; Addons paths
addons_path = /opt/odoo/odoo/addons,/mnt/extra-addons,/mnt/custom-addons,/mnt/osiserp-oca,/mnt/osiserp-themes,/mnt/osiserp-core

; Server settings
http_port = 8069
gevent_port = 8072
proxy_mode = True

; Logging
logfile = /var/log/odoo/odoo-server.log
log_level = warn
log_handler = :WARNING

; Performance tuning (calculated for $USER_SCALE scale)
workers = $WORKERS
max_cron_threads = $MAX_CRON
limit_memory_hard = $LIMIT_MEM_HARD
limit_memory_soft = $LIMIT_MEM_SOFT
limit_time_cpu = 1800
limit_time_real = 3600
limit_request = 8192
db_maxconn = $DB_MAXCONN

; Security
admin_passwd = $ADMIN_PASSWORD
list_db = False

; Data directory
data_dir = /var/lib/odoo

; Session settings
server_wide_modules = base,web
EOF

    log_success "Odoo configuration generated"
}

generate_docker_compose() {
    log_step "Generating Docker Compose Configuration..."
    
    cat > "$INSTALL_DIR/docker-compose.yml" << EOF
name: osiserp

services:
  odoo:
    build:
      context: .
      dockerfile: Dockerfile
    image: osiserp:${OSISERP_VERSION}
    container_name: osiserp-odoo
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "0.0.0.0:8069:8069"
      - "0.0.0.0:8072:8072"
    volumes:
      - ${DATA_DIR}/odoo-data:/var/lib/odoo
      - ./odoo.conf:/etc/odoo/odoo.conf:ro
      - ./custom/addons:/mnt/custom-addons:ro
      - ./custom/addons/osiserp_oca:/mnt/osiserp-oca:ro
      - ./custom/addons/osiserp_themes:/mnt/osiserp-themes:ro
      - ./custom/addons/osiserp_syscohada_reports:/mnt/osiserp-core:ro
      - ./modules:/mnt/extra-addons:ro
      - ${LOG_DIR}:/var/log/odoo
    environment:
      - HOST=db
      - PORT=5432
      - USER=$DB_USER
      - PASSWORD=$DB_PASSWORD
    restart: unless-stopped
    networks:
      - osiserp-network

  db:
    image: postgres:16-alpine
    container_name: osiserp-db
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_USER=$DB_USER
      - POSTGRES_PASSWORD=$DB_PASSWORD
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - ${DATA_DIR}/postgres-data:/var/lib/postgresql/data/pgdata
    restart: unless-stopped
    networks:
      - osiserp-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $DB_USER"]
      interval: 5s
      timeout: 5s
      retries: 5
    command:
      - "postgres"
      - "-c"
      - "shared_buffers=$PG_SHARED_BUFFERS"
      - "-c"
      - "work_mem=$PG_WORK_MEM"
      - "-c"
      - "maintenance_work_mem=$PG_MAINTENANCE_WORK_MEM"
      - "-c"
      - "effective_cache_size=$PG_EFFECTIVE_CACHE"

  nginx-proxy-manager:
    image: jc21/nginx-proxy-manager:latest
    container_name: osiserp-npm
    ports:
      - "80:80"
      - "443:443"
      - "81:81"
    volumes:
      - ${DATA_DIR}/npm-data:/data
      - ${DATA_DIR}/npm-letsencrypt:/etc/letsencrypt
    restart: unless-stopped
    networks:
      - osiserp-network

  filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: osiserp-files
    ports:
      - "8080:80"
    volumes:
      - ${DATA_DIR}/odoo-data/filestore:/srv/filestore
      - ${BACKUP_DIR}:/srv/backups
      - ${LOG_DIR}:/srv/logs
      - ${DATA_DIR}/filebrowser.db:/database.db
    environment:
      - FB_NOAUTH=false
      - FB_ROOT=/srv
    restart: unless-stopped
    networks:
      - osiserp-network

volumes:
  odoo-data:
  postgres-data:
  npm-data:
  npm-letsencrypt:

networks:
  osiserp-network:
    name: osiserp-network
EOF

    log_success "Docker Compose configuration generated"
}

generate_nginx_config() {
    log_step "Generating Nginx Configuration..."
    
    cat > "/etc/nginx/sites-available/osiserp" << EOF
upstream odoo {
    server 127.0.0.1:8069;
}

upstream odoo-chat {
    server 127.0.0.1:8072;
}

server {
    listen 80;
    server_name $DOMAIN_NAME;

    # Proxy settings
    proxy_read_timeout 720s;
    proxy_connect_timeout 720s;
    proxy_send_timeout 720s;

    # Proxy headers
    proxy_set_header X-Forwarded-Host \$host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header Host \$host;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    # Increase buffer size
    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    # Client body size for file uploads
    client_max_body_size 200m;

    # Longpolling / websocket
    location /websocket {
        proxy_pass http://odoo-chat;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /longpolling {
        proxy_pass http://odoo-chat;
    }

    # Static files caching
    location ~* /web/static/ {
        proxy_pass http://odoo;
        proxy_cache_valid 200 90m;
        proxy_buffering on;
        expires 864000;
        access_log off;
    }

    # Main Odoo
    location / {
        proxy_pass http://odoo;
        proxy_redirect off;
    }
}
EOF

    # Enable site
    ln -sf /etc/nginx/sites-available/osiserp /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    nginx -t > /dev/null 2>&1
    systemctl reload nginx
    
    log_success "Nginx configuration generated"
}

generate_dockerfile() {
    log_step "Generating Dockerfile..."
    
    cat > "$INSTALL_DIR/Dockerfile" << 'EOF'
FROM python:3.12-bookworm

LABEL maintainer="OsisERP"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ENV LANG=C.UTF-8

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl dirmngr fonts-noto-cjk gnupg \
        libssl-dev node-less npm \
        python3-magic python3-num2words python3-odf python3-pdfminer \
        python3-pip python3-phonenumbers python3-pyldap python3-qrcode \
        python3-renderpm python3-setuptools python3-slugify python3-vobject \
        python3-watchdog python3-xlrd python3-xlwt xz-utils \
        libpq-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev \
        libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev \
        libopenjp2-7-dev libtiff5-dev tk-dev tcl-dev git \
    && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf
RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install PostgreSQL client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update \
    && apt-get install --no-install-recommends -y postgresql-client-16 \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss
RUN npm install -g rtlcss

# Create odoo user
RUN useradd -ms /bin/bash odoo

WORKDIR /opt/odoo

# Clone OCA/OCB 18.0
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/OCB.git /opt/odoo/odoo

# Install Python dependencies
RUN pip3 install --no-cache-dir --break-system-packages -r /opt/odoo/odoo/requirements.txt \
    && pip3 install --no-cache-dir --break-system-packages \
        psycopg2-binary python-ldap num2words phonenumbers python-slugify \
        watchdog xlrd xlwt odfpy pdfminer.six qrcode vobject python-magic \
        ebaysdk pyopenssl firebase-admin google-auth

# Create directories
RUN mkdir -p /var/lib/odoo /var/log/odoo /mnt/extra-addons /mnt/custom-addons \
    /mnt/osiserp-oca /mnt/osiserp-themes /mnt/osiserp-core /home/odoo/.local \
    && chown -R odoo:odoo /opt/odoo /var/lib/odoo /var/log/odoo \
    /mnt/extra-addons /mnt/custom-addons /mnt/osiserp-oca \
    /mnt/osiserp-themes /mnt/osiserp-core /home/odoo/.local \
    && chmod -R 755 /usr/local/lib/python3.12/site-packages

COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

RUN chmod +x /entrypoint.sh && chown odoo:odoo /etc/odoo/odoo.conf

VOLUME ["/var/lib/odoo", "/mnt/custom-addons"]

EXPOSE 8069 8072

ENV ODOO_RC=/etc/odoo/odoo.conf
ENV PATH="/home/odoo/.local/bin:$PATH"

USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
EOF

    log_success "Dockerfile generated"
}

generate_entrypoint() {
    log_step "Generating Entrypoint Script..."
    
    cat > "$INSTALL_DIR/entrypoint.sh" << 'EOF'
#!/bin/bash
set -e

: ${HOST:=db}
: ${PORT:=5432}
: ${USER:=odoo}
: ${PASSWORD:=odoo}

wait_for_postgres() {
    echo "Waiting for PostgreSQL at $HOST:$PORT..."
    while ! pg_isready -h "$HOST" -p "$PORT" -U "$USER" -q; do
        sleep 1
    done
    echo "PostgreSQL is ready!"
}

case "$1" in
    odoo)
        shift
        wait_for_postgres
        exec /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf --db_host="$HOST" --db_port="$PORT" --db_user="$USER" --db_password="$PASSWORD" "$@"
        ;;
    -*)
        wait_for_postgres
        exec /opt/odoo/odoo/odoo-bin -c /etc/odoo/odoo.conf --db_host="$HOST" --db_port="$PORT" --db_user="$USER" --db_password="$PASSWORD" "$@"
        ;;
    *)
        exec "$@"
        ;;
esac
EOF

    chmod +x "$INSTALL_DIR/entrypoint.sh"
    log_success "Entrypoint script generated"
}

#===============================================================================
# OCA MODULE INSTALLATION
#===============================================================================

install_oca_modules() {
    log_step "Installing OCA Modules..."
    
    OCA_DIR="$INSTALL_DIR/custom/addons/osiserp_oca"
    mkdir -p "$OCA_DIR"
    
    TEMP_DIR=$(mktemp -d)
    
    clone_oca_repo() {
        local repo_url=$1
        local repo_name=$2
        local target_dir=$3
        
        log_info "Cloning $repo_name..."
        if git clone --depth 1 --branch 18.0 "$repo_url" "$TEMP_DIR/$repo_name" > /dev/null 2>&1; then
            if [[ -n "$target_dir" ]]; then
                cp -r "$TEMP_DIR/$repo_name" "$OCA_DIR/$target_dir"
            else
                cp -r "$TEMP_DIR/$repo_name"/* "$OCA_DIR/" 2>/dev/null || true
            fi
        else
            log_warning "Could not clone $repo_name (18.0 branch may not exist)"
        fi
    }
    
    # CORE (Always installed)
    log_info "Installing CORE modules..."
    clone_oca_repo "https://github.com/OCA/server-tools.git" "server-tools" "server-tools"
    clone_oca_repo "https://github.com/OCA/server-ux.git" "server-ux" "server-ux"
    clone_oca_repo "https://github.com/OCA/web.git" "web" "web"
    clone_oca_repo "https://github.com/OCA/reporting-engine.git" "reporting-engine" "reporting-engine"
    clone_oca_repo "https://github.com/OCA/server-brand.git" "server-brand" "server-brand"
    clone_oca_repo "https://github.com/OCA/server-env.git" "server-env" "server-env"
    
    # Document Management (File Manager)
    log_info "Installing DOCUMENT MANAGEMENT modules..."
    clone_oca_repo "https://github.com/OCA/dms.git" "dms" "dms"
    clone_oca_repo "https://github.com/OCA/knowledge.git" "knowledge" "knowledge"
    
    # Package-specific modules
    for package in "${SELECTED_PACKAGES[@]}"; do
        case $package in
            accounting)
                log_info "Installing ACCOUNTING modules..."
                clone_oca_repo "https://github.com/OCA/account-financial-tools.git" "account-financial-tools" "account-financial-tools"
                clone_oca_repo "https://github.com/OCA/account-financial-reporting.git" "account-financial-reporting" "account-financial-reporting"
                clone_oca_repo "https://github.com/OCA/account-payment.git" "account-payment" "account-payment"
                clone_oca_repo "https://github.com/OCA/mis-builder.git" "mis-builder" "mis-builder"
                clone_oca_repo "https://github.com/OCA/account-invoicing.git" "account-invoicing" "account-invoicing"
                clone_oca_repo "https://github.com/OCA/account-closing.git" "account-closing" "account-closing"
                clone_oca_repo "https://github.com/OCA/account-reconcile.git" "account-reconcile" "account-reconcile"
                clone_oca_repo "https://github.com/OCA/account-analytic.git" "account-analytic" "account-analytic"
                clone_oca_repo "https://github.com/OCA/bank-statement-import.git" "bank-statement-import" "bank-statement-import"
                clone_oca_repo "https://github.com/OCA/account-budgeting.git" "account-budgeting" "account-budgeting"
                clone_oca_repo "https://github.com/OCA/operating-unit.git" "operating-unit" "operating-unit"
                # Odoo Mates style accounting reports
                clone_oca_repo "https://github.com/CybroOdoo/CysbroAddons.git" "cybro-addons" "cybro-addons" || true
                ;;
            hr_payroll)
                log_info "Installing HR & PAYROLL modules..."
                clone_oca_repo "https://github.com/OCA/hr.git" "hr" "hr"
                clone_oca_repo "https://github.com/OCA/payroll.git" "payroll" "payroll"
                clone_oca_repo "https://github.com/OCA/hr-attendance.git" "hr-attendance" "hr-attendance"
                ;;
            manufacturing)
                log_info "Installing MANUFACTURING modules..."
                clone_oca_repo "https://github.com/OCA/manufacture.git" "manufacture" "manufacture"
                clone_oca_repo "https://github.com/OCA/manufacture-reporting.git" "manufacture-reporting" "manufacture-reporting"
                ;;
            inventory)
                log_info "Installing INVENTORY modules..."
                clone_oca_repo "https://github.com/OCA/stock-logistics-warehouse.git" "stock-logistics-warehouse" "stock-logistics-warehouse"
                clone_oca_repo "https://github.com/OCA/stock-logistics-workflow.git" "stock-logistics-workflow" "stock-logistics-workflow"
                clone_oca_repo "https://github.com/OCA/stock-logistics-barcode.git" "stock-logistics-barcode" "stock-logistics-barcode"
                ;;
            sales_crm)
                log_info "Installing SALES & CRM modules..."
                clone_oca_repo "https://github.com/OCA/sale-workflow.git" "sale-workflow" "sale-workflow"
                clone_oca_repo "https://github.com/OCA/crm.git" "crm" "crm"
                clone_oca_repo "https://github.com/OCA/partner-contact.git" "partner-contact" "partner-contact"
                ;;
            purchase)
                log_info "Installing PURCHASE modules..."
                clone_oca_repo "https://github.com/OCA/purchase-workflow.git" "purchase-workflow" "purchase-workflow"
                ;;
            project)
                log_info "Installing PROJECT modules..."
                clone_oca_repo "https://github.com/OCA/project.git" "project" "project"
                clone_oca_repo "https://github.com/OCA/timesheet.git" "timesheet" "timesheet"
                ;;
            syscohada)
                log_info "Installing SYSCOHADA modules..."
                # Copy from our custom modules
                if [[ -d "$INSTALL_DIR/modules/osiserp_syscohada_reports" ]]; then
                    cp -r "$INSTALL_DIR/modules/osiserp_syscohada_reports" "$INSTALL_DIR/custom/addons/"
                fi
                ;;
        esac
    done
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    
    log_success "OCA modules installed"
}

install_custom_modules() {
    log_step "Installing OsisERP Custom Modules..."
    
    CUSTOM_DIR="$INSTALL_DIR/custom/addons"
    
    # Copy theme modules
    if [[ -d "$INSTALL_DIR/modules/osiserp_themes" ]]; then
        cp -r "$INSTALL_DIR/modules/osiserp_themes" "$CUSTOM_DIR/"
    fi
    
    # Copy core modules
    if [[ -d "$INSTALL_DIR/modules/osiserp_core" ]]; then
        cp -r "$INSTALL_DIR/modules/osiserp_core" "$CUSTOM_DIR/"
    fi
    
    log_success "Custom modules installed"
}

#===============================================================================
# SECURITY CONFIGURATION
#===============================================================================

configure_firewall() {
    log_step "Configuring Firewall..."
    
    ufw --force reset > /dev/null 2>&1
    ufw default deny incoming > /dev/null 2>&1
    ufw default allow outgoing > /dev/null 2>&1
    ufw allow ssh > /dev/null 2>&1
    ufw allow http > /dev/null 2>&1
    ufw allow https > /dev/null 2>&1
    ufw allow 8069/tcp > /dev/null 2>&1  # Odoo
    ufw allow 8072/tcp > /dev/null 2>&1  # Odoo Longpolling
    ufw allow 81/tcp > /dev/null 2>&1    # Nginx Proxy Manager Admin
    ufw allow 8080/tcp > /dev/null 2>&1  # File Browser
    ufw --force enable > /dev/null 2>&1
    
    log_success "Firewall configured"
}

configure_fail2ban() {
    log_step "Configuring Fail2Ban..."
    
    cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log
EOF

    systemctl enable fail2ban > /dev/null 2>&1
    systemctl restart fail2ban > /dev/null 2>&1
    
    log_success "Fail2Ban configured"
}

setup_ssl() {
    if [[ "$USE_SSL" == true && "$DOMAIN_NAME" != "_" ]]; then
        log_step "Setting up SSL Certificate..."
        
        certbot --nginx -d "$DOMAIN_NAME" --non-interactive --agree-tos --email "admin@$DOMAIN_NAME" > /dev/null 2>&1 || {
            log_warning "SSL setup failed. You can run 'certbot --nginx -d $DOMAIN_NAME' manually later."
        }
        
        log_success "SSL certificate installed"
    fi
}

#===============================================================================
# SERVICE MANAGEMENT
#===============================================================================

create_systemd_service() {
    log_step "Creating Systemd Service..."
    
    cat > /etc/systemd/system/osiserp.service << EOF
[Unit]
Description=OsisERP Docker Compose Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable osiserp > /dev/null 2>&1
    
    log_success "Systemd service created"
}

start_services() {
    log_step "Starting OsisERP Services..."
    
    cd "$INSTALL_DIR"
    
    # Build and start
    docker-compose build > /dev/null 2>&1
    docker-compose up -d
    
    log_success "Services started"
}

#===============================================================================
# BACKUP CONFIGURATION
#===============================================================================

setup_backup_cron() {
    log_step "Setting up Automated Backups..."
    
    cat > /usr/local/bin/osiserp-backup << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/osiserp"
DATE=$(date +%Y%m%d_%H%M%S)
KEEP_DAYS=7

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup database
docker exec osiserp-db pg_dump -U odoo osiserp | gzip > "$BACKUP_DIR/db_$DATE.sql.gz"

# Backup filestore
tar -czf "$BACKUP_DIR/filestore_$DATE.tar.gz" -C /var/lib/osiserp/odoo-data .

# Remove old backups
find "$BACKUP_DIR" -type f -mtime +$KEEP_DAYS -delete

echo "Backup completed: $DATE"
EOF

    chmod +x /usr/local/bin/osiserp-backup
    
    # Add cron job (daily at 2 AM)
    (crontab -l 2>/dev/null | grep -v osiserp-backup; echo "0 2 * * * /usr/local/bin/osiserp-backup >> /var/log/osiserp/backup.log 2>&1") | crontab -
    
    log_success "Backup cron job configured"
}

#===============================================================================
# CREDENTIALS STORAGE
#===============================================================================

save_credentials() {
    log_step "Saving Credentials..."
    
    cat > /root/.osiserp_credentials << EOF
#===============================================================================
# OsisERP Credentials - KEEP THIS FILE SECURE!
# Generated: $(date)
#===============================================================================

# Database
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD

# Odoo Admin
ADMIN_PASSWORD=$ADMIN_PASSWORD

# Domain
DOMAIN=$DOMAIN_NAME
USE_SSL=$USE_SSL

# Installation
INSTALL_DIR=$INSTALL_DIR
DATA_DIR=$DATA_DIR

# Access URLs
EOF

    if [[ "$DOMAIN_NAME" != "_" ]]; then
        if [[ "$USE_SSL" == true ]]; then
            echo "URL=https://$DOMAIN_NAME" >> /root/.osiserp_credentials
        else
            echo "URL=http://$DOMAIN_NAME" >> /root/.osiserp_credentials
        fi
    else
        echo "URL=http://$PUBLIC_IP" >> /root/.osiserp_credentials
    fi
    
    chmod 600 /root/.osiserp_credentials
    
    log_success "Credentials saved to /root/.osiserp_credentials"
}

#===============================================================================
# MANAGEMENT SCRIPT
#===============================================================================

create_management_script() {
    log_step "Creating Management Script..."
    
    cat > /usr/local/bin/osiserp << 'MGMT_EOF'
#!/bin/bash

INSTALL_DIR="/opt/osiserp"

case "$1" in
    start)
        echo "Starting OsisERP..."
        cd "$INSTALL_DIR" && docker-compose up -d
        ;;
    stop)
        echo "Stopping OsisERP..."
        cd "$INSTALL_DIR" && docker-compose down
        ;;
    restart)
        echo "Restarting OsisERP..."
        cd "$INSTALL_DIR" && docker-compose restart
        ;;
    status)
        cd "$INSTALL_DIR" && docker-compose ps
        ;;
    logs)
        cd "$INSTALL_DIR" && docker-compose logs -f ${2:-odoo}
        ;;
    backup)
        /usr/local/bin/osiserp-backup
        ;;
    update)
        echo "Updating OsisERP..."
        cd "$INSTALL_DIR"
        git pull
        docker-compose build
        docker-compose up -d
        ;;
    shell)
        docker exec -it osiserp-odoo bash
        ;;
    dbshell)
        docker exec -it osiserp-db psql -U odoo
        ;;
    install-module)
        if [[ -z "$2" ]]; then
            echo "Usage: osiserp install-module <module_name>"
            exit 1
        fi
        docker exec osiserp-odoo odoo -i "$2" -d osiserp --stop-after-init
        ;;
    update-module)
        if [[ -z "$2" ]]; then
            echo "Usage: osiserp update-module <module_name>"
            exit 1
        fi
        docker exec osiserp-odoo odoo -u "$2" -d osiserp --stop-after-init
        ;;
    credentials)
        cat /root/.osiserp_credentials
        ;;
    *)
        echo "OsisERP Management Commands:"
        echo "  osiserp start          - Start all services"
        echo "  osiserp stop           - Stop all services"
        echo "  osiserp restart        - Restart all services"
        echo "  osiserp status         - Show service status"
        echo "  osiserp logs [service] - View logs (default: odoo)"
        echo "  osiserp backup         - Run manual backup"
        echo "  osiserp update         - Update OsisERP"
        echo "  osiserp shell          - Open Odoo container shell"
        echo "  osiserp dbshell        - Open PostgreSQL shell"
        echo "  osiserp install-module <name> - Install a module"
        echo "  osiserp update-module <name>  - Update a module"
        echo "  osiserp credentials    - Show saved credentials"
        ;;
esac
MGMT_EOF

    chmod +x /usr/local/bin/osiserp
    
    log_success "Management script created: /usr/local/bin/osiserp"
}

#===============================================================================
# FINAL SUMMARY
#===============================================================================

print_summary() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}       OsisERP Installation Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}Access Information:${NC}"
    if [[ "$DOMAIN_NAME" != "_" ]]; then
        if [[ "$USE_SSL" == true ]]; then
            echo -e "  URL:            ${GREEN}https://$DOMAIN_NAME${NC}"
        else
            echo -e "  URL:            ${GREEN}http://$DOMAIN_NAME${NC}"
        fi
    else
        echo -e "  URL:            ${GREEN}http://$PUBLIC_IP${NC}"
    fi
    echo ""
    echo -e "${WHITE}Credentials:${NC}"
    echo -e "  Database:       ${CYAN}$DB_NAME${NC}"
    echo -e "  DB User:        ${CYAN}$DB_USER${NC}"
    echo -e "  DB Password:    ${CYAN}$DB_PASSWORD${NC}"
    echo -e "  Admin Password: ${CYAN}$ADMIN_PASSWORD${NC}"
    echo ""
    echo -e "${WHITE}Management Commands:${NC}"
    echo -e "  ${YELLOW}osiserp start${NC}     - Start services"
    echo -e "  ${YELLOW}osiserp stop${NC}      - Stop services"
    echo -e "  ${YELLOW}osiserp logs${NC}      - View logs"
    echo -e "  ${YELLOW}osiserp backup${NC}    - Run backup"
    echo -e "  ${YELLOW}osiserp status${NC}    - Check status"
    echo ""
    echo -e "${WHITE}Files:${NC}"
    echo -e "  Installation:   ${CYAN}$INSTALL_DIR${NC}"
    echo -e "  Data:           ${CYAN}$DATA_DIR${NC}"
    echo -e "  Logs:           ${CYAN}$LOG_DIR${NC}"
    echo -e "  Backups:        ${CYAN}$BACKUP_DIR${NC}"
    echo -e "  Credentials:    ${CYAN}/root/.osiserp_credentials${NC}"
    echo ""
    echo -e "${WHITE}Selected Packages:${NC} ${CYAN}${SELECTED_PACKAGES[*]}${NC}"
    echo ""
    echo -e "${YELLOW}Note: It may take 1-2 minutes for Odoo to fully start.${NC}"
    echo -e "${YELLOW}Check status with: osiserp logs${NC}"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================

main() {
    print_banner
    check_root
    check_os
    
    echo ""
    if ! confirm "This will install OsisERP on this server. Continue?"; then
        log_info "Installation cancelled."
        exit 0
    fi
    
    # Gather information
    analyze_system
    get_user_count
    calculate_performance_settings
    select_modules
    configure_domain
    configure_database
    
    echo ""
    log_step "Starting Installation..."
    echo ""
    
    # Install components
    install_dependencies
    install_docker
    install_nginx
    clone_repository
    create_directories
    
    # Generate configurations
    generate_dockerfile
    generate_entrypoint
    generate_odoo_config
    generate_docker_compose
    generate_nginx_config
    
    # Install modules
    install_oca_modules
    install_custom_modules
    
    # Security
    configure_firewall
    configure_fail2ban
    
    # Services
    create_systemd_service
    start_services
    
    # SSL (after services are running)
    setup_ssl
    
    # Backup & Management
    setup_backup_cron
    save_credentials
    create_management_script
    
    # Done!
    print_summary
}

# Run main function
main "$@"
