#!/bin/bash

# Set a log file
LOGFILE="/var/log/setup.log"

# Reset the log file
echo "" > $LOGFILE

# Function to write to log file
log_message() {
    echo "$1" >> "$LOGFILE"
}

# Function to display console messages
console_message() {
    flg="${2:-n}"
    str=$1
    if [ $flg == 1 ]; then
        str="$1\n"
    fi
    echo -e $str
    echo -e "\n----> $1 <----\n" >> $LOGFILE
}

# Function to execute command and log messages
execute_and_log() {
    log_message "Executing: $1"
    eval $1 >> $LOGFILE 2>&1
    status=$?
    if [ $status -ne 0 ]; then
        echo "Error: '$1' failed with status $status. Check /var/log/setup.log."
        exit 1
    fi
    return $status
}

# Function to exectute and log messages with progress indicator
execute_and_log_with_progress() {
    log_message "Executing: $1"
    eval $1 >> $LOGFILE 2>&1 &
    pid=$!
    progress_indicator=('|' '/' '-' '|')
    index=0

    while kill -0 $pid 2> /dev/null; do
        echo -ne "${progress_indicator[$index]} Command is still running...\r"
        sleep 1
        let "index = (index + 1) % 4"
    done
    echo ""
    wait $pid
    status=$?
    if [ $status -ne 0 ]; then
        echo "Error: '$1' failed with status $status. Check /var/log/setup.log."
        exit 1
    else
        echo "" >> $LOGFILE
    fi
    return $status
}

# Function to display progress messages
progress_message() {
    echo "========================================================" | tee -a $LOGFILE
    echo $1 | tee -a $LOGFILE
    echo "========================================================" | tee -a $LOGFILE
}

# Change nameservers
progress_message "Changing nameservers..."
execute_and_log "echo -e \"DNS=8.8.8.8 1.1.1.1\" >> /etc/systemd/resolved.conf"
execute_and_log "systemctl restart systemd-resolved"
console_message "Changed nameservers." 1

# Update Ubuntu
progress_message "Updating Ubuntu... (This may take some time...)"
execute_and_log "systemctl restart systemd-timesyncd"
execute_and_log_with_progress "ping -c 2 8.8.8.8"
console_message "Checked internet connectivity. (Step 1/3)"
execute_and_log_with_progress "apt-get update -y"
console_message "Updated Ubuntu. (Step 2/3)"
execute_and_log_with_progress "DEBIAN_FRONTEND=noninteractive apt-get upgrade -y"
console_message "Upgraded Ubuntu. (Step 3/3)" 1

# Install Docker
progress_message "Installing Docker... (This may take some time...)"
execute_and_log_with_progress "apt-get update && apt-get install -y ca-certificates curl gnupg lsb-release"
execute_and_log "mkdir -p /etc/apt/keyrings"
execute_and_log "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
execute_and_log "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null"
execute_and_log_with_progress "apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin"
console_message "Installed Docker." 1

# Install tinet
progress_message "Installing tinet..."
execute_and_log "cp /mnt/c/tinet/tinet /usr/bin/tinet"
execute_and_log "chmod +x /usr/bin/tinet"
console_message "Installed tinet." 1

progress_message "Setup complete."
