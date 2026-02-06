#!/bin/bash

# ============================================
# Netdata Cleanup Script
# ============================================
# This script removes Netdata and all related
# files from the system
# ============================================

# Color codes for terminal output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  Netdata Uninstallation${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Usage: sudo ./cleanup.sh"
    exit 1
fi

# Confirm before proceeding with uninstallation
read -p "Are you sure you want to uninstall Netdata? (y/N): " confirm

if [[ $confirm != "y" && $confirm != "Y" ]]; then
    echo "Cancelled."
    exit 0
fi

# Stop the Netdata service
echo -e "${YELLOW}Stopping Netdata service...${NC}"
systemctl stop netdata

# Disable Netdata from starting on boot
echo -e "${YELLOW}Disabling service...${NC}"
systemctl disable netdata

# Remove Netdata files and directories
echo -e "${YELLOW}Removing files...${NC}"

# Try to use official uninstaller if available
if [ -f /usr/libexec/netdata/netdata-uninstaller.sh ]; then
    # Run official uninstaller with yes and force flags
    /usr/libexec/netdata/netdata-uninstaller.sh --yes --force
else
    # Manual uninstallation if official script not found
    # Remove configuration directory
    rm -rf /etc/netdata
    
    # Remove cache directory
    rm -rf /var/cache/netdata
    
    # Remove library directory (contains databases)
    rm -rf /var/lib/netdata
    
    # Remove log directory
    rm -rf /var/log/netdata
    
    # Remove shared files directory
    rm -rf /usr/share/netdata
    
    # Remove main binary
    rm -f /usr/sbin/netdata
    
    # Remove systemd service file
    rm -f /etc/systemd/system/netdata.service
    
    # Remove netdata user account
    userdel netdata 2>/dev/null
fi

# Clean up temporary files
echo -e "${YELLOW}Cleaning temporary files...${NC}"
rm -f /tmp/netdata-kickstart.sh
rm -f /tmp/test_file
rm -f /tmp/test_download

# Reload systemd daemon to recognize changes
systemctl daemon-reload

# Display success message
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Netdata has been uninstalled successfully${NC}"
echo -e "${GREEN}========================================${NC}\n"