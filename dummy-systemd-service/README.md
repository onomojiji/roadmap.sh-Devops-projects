# Roadmap.sh-Dummy-Systemd-Service
<https://roadmap.sh/projects/dummy-systemd-service>

# Steps to create, configure and activate a daemon on Linux

> #### NB : NB: For this Lab we will use Ubuntu server 24.04 LTS as test machine

> Our daemon will be a daemon that sends a telegram notification to a user each time there is an ssh connection attempt

## 1. Create the custom script
> By default, we create user scripts in the /usr/local/bin/ folder
>
> ````
> sudo nano /usr/local/bin/ssh-log-monitor.sh
> ````

> Paste the content below into the file
>
> ````
> #!/bin/bash
>
> TELEGRAM_BOT_TOKEN="875XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
> TELEGRAM_CHAT_ID="875XXXXX"
> QUEUE_DIR="/var/spool/ssh-telegram"
> LAST_POSITION_FILE="/var/lib/ssh-telegram/last_position"
>
> mkdir -p "$QUEUE_DIR" "$(dirname "$LAST_POSITION_FILE")"
>
> send_telegram() {
>    local message="$1"
>    curl -s -X POST \
>        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
>        -d "chat_id=${TELEGRAM_CHAT_ID}" \
>        -d "text=${message}" \
>        -d "parse_mode=HTML" \
>        --connect-timeout 10 \
>        --max-time 15 \
>        > /dev/null 2>&1
>    return $?
> }
>
> queue_message() {
>    local message="$1"
>    local timestamp=$(date +%s%N)
>    echo "$message" > "${QUEUE_DIR}/${timestamp}.msg"
> }
>
> process_queue() {
>    if ! curl -s --connect-timeout 5 --max-time 10 https://api.telegram.org > /dev/null 2>&1; then
>        return 1
>    fi
>    
>    for msg_file in "$QUEUE_DIR"/*.msg 2>/dev/null; do
>        [ -f "$msg_file" ] || continue
>        message=$(cat "$msg_file")
>        if send_telegram "$message"; then
>            rm -f "$msg_file"
>        else
>            break
>        fi
>    done
> }
>
> # Read the last position
> LAST_POS=0
> [ -f "$LAST_POSITION_FILE" ] && LAST_POS=$(cat "$LAST_POSITION_FILE")
>
> # Parse the new logs
> journalctl -u sshd -o json --since "@${LAST_POS}" | while read -r > line; do
>    # Extract JSON fields
>    timestamp=$(echo "$line" | jq -r '.__REALTIME_TIMESTAMP')
>    message_text=$(echo "$line" | jq -r '.MESSAGE')
>    
>    # Save the position
>    [ -n "$timestamp" ] && echo "$timestamp" > "$LAST_POSITION_FILE"
>    
>    # Detect SSH events
>    if echo "$message_text" | grep -qE "(Accepted|Failed) (password|publickey)"; then
>        user=$(echo "$message_text" | grep -oP '(?<=for )\w+' | head -1)
>        ip=$(echo "$message_text" | grep -oP '(?<=from )[0-9\.]+' | head -1)
>       
>        if echo "$message_text" | grep -q "Accepted"; then
>            status="<b>Status:</b> SUCCESS"
>        else
>            status="<b>Status:</b> FAILED"
>        fi
>   
>        date_formatted=$(date -d "@$((timestamp/1000000))" '+%Y-%m-%d %H:%M:%S %Z')
>       
>        msg="<b>SSH Connection Attempt</b>
>
> <b>Date:</b> ${date_formatted}
> <b>User:</b> ${user}
> <b>IP:</b> ${ip}
> ${status}"
>       
>        if ! send_telegram "$msg"; then
>            queue_message "$msg"
>        else
>            process_queue
>        fi
>    fi
> done
> ````

## 2. Make the script executable 
````
sudo chmod +x /usr/local/bin/telegram-am-pm-notify.sh
````

## 3. Then create the telegram service
> Just like for user scripts, there is also a specific default folder in which we create services. This one is: /etc/systemd/system/

> ````
> sudo nano /etc/systemd/system/ssh-telegram-notify.service
>````

> Paste the content below into the file and save
> ````
> [Unit]
> Description=SSH Telegram Notification Service
> After=network-online.target sshd.service
> Wants=network-online.target
>
> [Service]
> Type=oneshot
> ExecStart=/usr/local/bin/ssh-log-monitor.sh
> StandardOutput=journal
> StandardError=journal
>
> [Install]
> WantedBy=multi-user.target
> ````

## 4. Create the timer
> The timer here is a script responsible for event monitoring on the service in order to detect events.

> For this we need to create a .timer file in the etc/systemd/system/ folder
>
> ````
> sudo nano /etc/systemd/system/ssh-telegram-notify.timer
> ````

> Paste the content below into the file and save
>
> ````
> [Unit]
> Description=SSH Telegram Notification Timer
> Requires=ssh-telegram-notify.service
>
> [Timer]
> OnBootSec=1min
> OnUnitActiveSec=30s
> AccuracySec=1s
>
> [Install]
> WantedBy=timers.target 
> ````

## 5. Reload the daemon list then activate ours at system startup

> ### 5.1. Reload the daemons list
>
> ````
> sudo systemctl daemon-reload
> ````

> ### 5.2. Enable the service at system startup
>
> ````
> sudo systemctl enable ssh-telegram-notify.timer
> ````

> ### 5.3. Start the service
>
> ````
> sudo systemctl start ssh-telegram-notify.timer
> ````

## 6. Check the service status
````
sudo systemctl status ssh-telegram-notify.timer
````
Now we can test by trying to connect via ssh to our server.