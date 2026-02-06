# Simple Monitoring with Netdata

<https://roadmap.sh/projects/simple-monitoring-dashboard>

## Requirements

- Linux system (Ubuntu 20.04+ recommended)
- Root/sudo access
- Internet connection for package downloads
- Minimum 512MB RAM
- 500MB free disk space

## Quick Start

### 1. Clone or Download the Scripts

Make sure you have all three scripts in the same directory:
- `setup.sh` - Installation script
- `test_dashboard.sh` - Testing script
- `cleanup.sh` - Removal script

### 2. Make Scripts Executable

```bash
chmod +x setup.sh test_dashboard.sh cleanup.sh
```

### 3. Install Netdata

```bash
sudo ./setup.sh
```

This will:
- Update system packages
- Install Netdata and dependencies
- Configure custom CPU alerts (warning at 80%, critical at 95%)
- Set up the dashboard with extended data retention
- Start the monitoring service

### 4. Access the Dashboard

Open your web browser and navigate to:
- **Local access**: `http://localhost:19999`
- **Remote access**: `http://YOUR_SERVER_IP:19999`

### 5. Test the Monitoring

```bash
./test_dashboard.sh
```

Choose from available tests:
1. **CPU Test** - Generates processor load for 30 seconds
2. **Memory Test** - Allocates 500MB of RAM
3. **Disk Test** - Performs intensive read/write operations
4. **Network Test** - Downloads a test file
5. **Full Test** - Runs all tests sequentially

### 6. Clean Up (Optional)

When you're done with the project:

```bash
sudo ./cleanup.sh
```

This removes Netdata and all associated files from your system.


## Script Details

### setup.sh

**Purpose**: Automates Netdata installation and configuration

**What it does**:
- Checks for root privileges
- Updates package repositories
- Installs Netdata using official kickstart script
- Creates custom CPU usage alert
- Configures dashboard settings
- Verifies successful installation

**Key Configuration**:
```bash
# Alert threshold
CPU warning: 80%
CPU critical: 95%

# Data retention
Storage: 512MB
Update interval: 1 second
```

### test_dashboard.sh

**Purpose**: Generates system load for testing monitoring

**Available Tests**:

1. **CPU Test**
   - Creates load on all CPU cores
   - Duration: 30 seconds
   - Method: dd command to /dev/null

2. **Memory Test**
   - Allocates 500MB RAM
   - Duration: 20 seconds
   - Method: Python list allocation

3. **Disk Test**
   - Creates 500MB file
   - Performs 5 read cycles
   - Cleans up automatically

4. **Network Test**
   - Downloads 100MB test file
   - Cleans up after completion

### cleanup.sh

**Purpose**: Completely removes Netdata from the system

**What it does**:
- Confirms action with user
- Stops and disables Netdata service
- Removes all Netdata directories
- Deletes configuration files
- Removes netdata user account
- Cleans temporary files

## Dashboard Exploration

### Key Sections to Explore

1. **System Overview**
   - Total CPU usage
   - RAM utilization
   - Disk I/O rates
   - Network traffic

2. **CPU Details**
   - Per-core usage
   - System vs user time
   - Load average

3. **Memory**
   - Used vs available
   - Cache and buffers
   - Swap usage

4. **Disk**
   - Read/write speeds
   - I/O operations
   - Disk utilization

5. **Network**
   - Bandwidth usage
   - Packets transmitted
   - Connection states

6. **Alerts**
   - Active warnings
   - Alert history
   - Custom CPU alert status

## Customization Ideas

### Add More Alerts

Create new alert files in `/etc/netdata/health.d/`:

```bash
# Example: Memory alert
sudo nano /etc/netdata/health.d/memory_custom.conf
```

### Modify Dashboard Settings

Edit the main configuration:

```bash
sudo nano /etc/netdata/netdata.conf
```

### Add Custom Charts

Configure plugins in:

```bash
sudo nano /etc/netdata/python.d/
```

## Troubleshooting

### Netdata Won't Start

```bash
# Check service status
sudo systemctl status netdata

# View logs
sudo journalctl -u netdata -n 50
```

### Dashboard Not Accessible

```bash
# Check if Netdata is listening
sudo netstat -tlnp | grep 19999

# Verify firewall settings
sudo ufw status
```

### High Resource Usage

```bash
# Reduce update frequency
# Edit /etc/netdata/netdata.conf
[db]
    update every = 2  # Change from 1 to 2 seconds
```
