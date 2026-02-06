#!/bin/bash

# ============================================
# Netdata Monitoring Setup Script
# ============================================
# This script automates the installation and 
# configuration of Netdata on a Linux system
# ============================================

# Color codes for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Netdata Monitoring Installation${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Usage: sudo ./setup.sh"
    exit 1
fi

# Step 1: Update system packages
echo -e "${YELLOW}[1/5] Updating system packages...${NC}"
apt update -qq

# Step 2: Install required dependencies
echo -e "${YELLOW}[2/5] Installing dependencies...${NC}"
apt install -y curl wget > /dev/null 2>&1

# Step 3: Install Netdata using official kickstart script
echo -e "${YELLOW}[3/5] Installing Netdata...${NC}"
# Download the official installation script
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh
# Run installation with stable channel, no telemetry, and non-interactive mode
sh /tmp/netdata-kickstart.sh --stable-channel --disable-telemetry --non-interactive

# Verify that Netdata service is running
if ! systemctl is-active --quiet netdata; then
    echo -e "${RED}Error: Netdata failed to start${NC}"
    exit 1
fi

# Step 4: Configure custom settings
echo -e "${YELLOW}[4/5] Configuring Netdata...${NC}"

# Create custom CPU alert configuration
# This alert will trigger when CPU usage exceeds 80% (warning) or 95% (critical)
cat > /etc/netdata/health.d/cpu_custom.conf << 'EOF'
# Custom CPU usage alert
alarm: cpu_usage_high
   on: system.cpu
class: Utilization
 type: System
component: CPU
   os: linux
hosts: *
 calc: $system + $user
units: %
every: 10s
 warn: $this > 80
 crit: $this > 95
delay: down 5m multiplier 1.5 max 1h
 info: CPU usage is above 80%
   to: sysadmin
EOF

# Customize main Netdata configuration
# - Increase data retention period
# - Enable dbengine for better performance
# - Allow connections from all interfaces
cat >> /etc/netdata/netdata.conf << 'EOF'

[db]
    # Database engine mode for better performance and data retention
    mode = dbengine
    storage tiers = 3
    update every = 1
    dbengine multihost disk space MB = 512

[web]
    # Web interface configuration
    bind to = 0.0.0.0
    allow connections from = *
EOF

# Step 5: Restart Netdata to apply configuration changes
echo -e "${YELLOW}[5/5] Restarting Netdata...${NC}"
systemctl restart netdata

# Get system IP address for dashboard access
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Display success message and access information
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"
echo -e "Dashboard URL: ${YELLOW}http://${IP_ADDRESS}:19999${NC}"
echo -e "Local access: ${YELLOW}http://localhost:19999${NC}\n"
echo -e "Configured alert: CPU usage > 80%\n"
echo -e "Use ${YELLOW}./test_dashboard.sh${NC} to test the monitoring system\n"