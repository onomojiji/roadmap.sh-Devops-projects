#! /bin/bash

# System Logs directory
LOG_DIR=/var/log/

# Backup logs directory
BACKUP_DIR=~/backup/logs/

# check root running command
is_root(){
    # Check if script is run as root
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${RED}Error: This script must be run as root${NC}"
        echo "Usage: sudo ./log-archive-tool.sh"
        exit 1
    fi
}

# check directories existence
get_or_create_dirs(){
    # check if the sytem logs directory exist
    if [ ! -d "$LOG_DIR" ]; then
        echo "Error: System Log directory does not exist."
        LOG_DIR=""
    else
        echo "System Log directory set to $LOG_DIR"
    fi

    # check if backup logs directory exist
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Error: Backup log directory does not exist."

        # create the directory
        mkdir -p $BACKUP_DIR
    else
        echo "Backup Log directory set to $BACKUP_DIR"
    fi
}

archive_logs(){
    # get actual date time
    NOW=$(date "+%Y_%m_%d_%H:%M:%S")

    # Archive System Logs
    tar -czvf "Backup_$NOW".tar.gz $LOG_DIR

    echo "Archive created successfully."

    echo "Backup_$NOW.tar.gz stored"
}

main(){
    echo "=================="
    echo "LOG ARCHIVE BACKUP"
    echo "=================="

    get_or_create_dirs
    echo ""

    archive_logs
    echo ""
}