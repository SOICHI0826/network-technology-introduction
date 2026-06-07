#!/bin/bash

# Set success flag
success_flag=true

# Set a log file
LOGFILE="/var/log/check.log"

# Function to display console messages
console_message() {
    flg="${2:-n}"
    echo "$1"
    if [ $flg = n ]; then
        echo ""
    fi
    if [ $flg != 1 ]; then
        echo -e "$1\n" >> $LOGFILE
    fi
}

# Function to execute command and log messages
execute_and_log() {
    echo "Executing: $1" >> $LOGFILE
    eval $1 2>&1 >> $LOGFILE
    echo "" >> $LOGFILE
}

# Function to display progress messages
progress_message() {
    echo "========================================================" | tee -a $LOGFILE
    echo $1 | tee -a $LOGFILE
    echo "========================================================" | tee -a $LOGFILE
}

# Reset the log file
echo "" | tee $LOGFILE

# Check /etc/systemd/resolved.conf configuration
progress_message "Checking /etc/systemd/resolved.conf configuration..."
if [ -f /etc/systemd/resolved.conf ]; then
    console_message "/etc/systemd/resolved.conf exists." 0
    if grep -q "DNS=8.8.8.8 1.1.1.1" /etc/systemd/resolved.conf; then
        console_message "Nameservers are set correctly in /etc/systemd/resolved.conf."
        execute_and_log "cat /etc/systemd/resolved.conf"
    else
        console_message "Nameservers are not set correctly in /etc/systemd/resolved.conf. <---!!!!!"
        execute_and_log "cat /etc/systemd/resolved.conf"
        success_flag=false
    fi
else
    console_message "/etc/systemd/resolved.conf does not exist. <---!!!!!"
    success_flag=false
fi

# Check Docker Installation
progress_message "Checking Docker installation..."
if docker --version > /dev/null 2>&1; then
    console_message "Docker is installed and accessible."
    execute_and_log "docker --version"
else
    console_message "Docker is not installed or not accessible. <---!!!!!"
    success_flag=false
fi

# Check tinet Installation
progress_message "Checking tinet installation..."
if tinet --version > /dev/null 2>&1; then
    console_message "tinet is installed and accessible."
    execute_and_log "tinet --version"
else
    console_message "tinet is not installed or not accessible. <---!!!!!"
    success_flag=false
fi

# Check basic configurations
progress_message "Checking Basic configuration..."

### Check Hostname
console_message "Hostname is $(hostname)" 0
execute_and_log "hostname"

### Check Docker Service Status
echo "--------------------------------------------------------" >> $LOGFILE
if service docker status > /dev/null 2>&1; then
    console_message "Docker service is running." 0
else
    console_message "Docker service is not running. <---!!!!!" 0
    success_flag=false
fi
execute_and_log "service docker status"

### Check Login User
echo "--------------------------------------------------------" >> $LOGFILE
if [ $(whoami) == "root" ]; then
    console_message "Logged in as 'root'." 0
else
    console_message "Not logged in as 'root', but as $(whoami) <---!!!!!" 0
    success_flag=false
fi
execute_and_log "whoami"

echo ""

### Final Progress Message
if [ "$success_flag" = true ] ; then
    progress_message "All checks passed successfully."
else
    progress_message "Some checks didn't pass. Check /var/log/check.log."
fi
