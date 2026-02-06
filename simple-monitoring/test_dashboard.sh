#!/bin/bash

# ============================================
# Netdata Dashboard Testing Script
# ============================================
# This script generates various system loads
# to test the monitoring dashboard
# ============================================

# Color codes for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Netdata Dashboard Testing${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Verify that Netdata is running
if ! systemctl is-active --quiet netdata; then
    echo -e "${RED}Error: Netdata is not running${NC}"
    echo "Please run: sudo ./setup.sh first"
    exit 1
fi

# Display dashboard access information
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo -e "${YELLOW}Dashboard URL: http://${IP_ADDRESS}:19999${NC}\n"

# Display test menu
echo -e "${YELLOW}Choose a test type:${NC}"
echo "1) CPU Test (processor load for 30s)"
echo "2) Memory Test (RAM allocation)"
echo "3) Disk Test (intensive read/write)"
echo "4) Network Test (download test)"
echo "5) Full Test (run all tests)"
echo ""
read -p "Your choice (1-5): " choice

# Function to generate CPU load
test_cpu() {
    echo -e "\n${YELLOW}[CPU TEST] Generating CPU load for 30 seconds...${NC}"
    echo "Open the dashboard to watch CPU graphs increase!"
    
    # Create load on all CPU cores using dd command
    # This will max out each core by reading from /dev/zero
    for i in $(seq 1 $(nproc)); do
        dd if=/dev/zero of=/dev/null bs=1M &
    done
    
    # Wait for 30 seconds
    sleep 30
    
    # Kill all dd processes to stop the load
    killall dd 2>/dev/null
    echo -e "${GREEN}✓ CPU test completed${NC}"
}

# Function to test memory allocation
test_memory() {
    echo -e "\n${YELLOW}[MEMORY TEST] Allocating 500MB of RAM...${NC}"
    
    # Use Python to allocate memory
    # This creates a large list in memory
    python3 << 'PYTHON'
import time
print("Allocating memory...")
# Allocate approximately 500MB (125M integers * 4 bytes each)
data = [0] * (125 * 1024 * 1024)
print("Memory allocated. Holding for 20 seconds...")
time.sleep(20)
print("Releasing memory...")
PYTHON
    
    echo -e "${GREEN}✓ Memory test completed${NC}"
}

# Function to test disk I/O
test_disk() {
    echo -e "\n${YELLOW}[DISK TEST] Intensive write/read operations...${NC}"
    
    # Create a 500MB test file
    # if: input file (/dev/zero provides unlimited zeros)
    # of: output file
    # bs: block size
    # count: number of blocks
    dd if=/dev/zero of=/tmp/test_file bs=1M count=500 2>/dev/null
    
    # Perform intensive read operations
    # Read the file 5 times and discard output
    for i in {1..5}; do
        cat /tmp/test_file > /dev/null
    done
    
    # Clean up test file
    rm -f /tmp/test_file
    echo -e "${GREEN}✓ Disk test completed${NC}"
}

# Function to test network activity
test_network() {
    echo -e "\n${YELLOW}[NETWORK TEST] Downloading test file...${NC}"
    
    # Download a test file to generate network traffic
    # Using a public speed test file
    wget -O /tmp/test_download http://speedtest.ftp.otenet.gr/files/test100Mb.db 2>&1 | grep -E "saved|downloaded" || echo "Download completed"
    
    # Clean up downloaded file
    rm -f /tmp/test_download
    echo -e "${GREEN}✓ Network test completed${NC}"
}

# Execute selected test based on user choice
case $choice in
    1) test_cpu ;;
    2) test_memory ;;
    3) test_disk ;;
    4) test_network ;;
    5)
        # Run all tests sequentially
        test_cpu
        test_memory
        test_disk
        test_network
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

# Display completion message
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Testing completed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nCheck the dashboard to see the test impact"
echo -e "Dashboard: ${YELLOW}http://${IP_ADDRESS}:19999${NC}\n"