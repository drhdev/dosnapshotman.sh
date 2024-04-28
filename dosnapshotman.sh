!/bin/bash

# Script Name: dosnapshotman.sh
# Versio: 0.1
# License: GNU General Public License v3.0
# Description: This script automates the process of taking snapshots of DigitalOcean droplets,
# retaining only the last two snapshots for each droplet and optionally sending status notifications via Telegram.
# This script supports multiple DigitalOcean accounts and allows user to view verbose output or receive Telegram messages.
#
# Installation:
# 1. Ensure 'doctl' (DigitalOcean command line tool) is installed on your system.
#    You can install it via snap with the command 'sudo snap install doctl'.
# 2. Configure the script with your DigitalOcean and Telegram API keys and droplet IDs.
# 3. Set the appropriate permissions for the script: 'chmod +x dosnapshotman.sh'.
# 4. (Optional) Set up environment variables or secure vault storage for API keys to enhance security.
# 5. Ensure that the script has permissions to write to the log file path specified within.
#
# Usage:
# Run the script with the following options:
#  -v: Verbose mode. Outputs the status messages to the console.
#  -t: Telegram mode. Sends status messages via Telegram to the specified chat ID.
# You can combine options to activate both modes:
#  ./dosnapshotman.sh -v -t
#
# Ensure the LOG_FILE path in the script is writable. Adjust path and permissions as necessary.
# You may also need to configure Telegram bot settings as per your requirements.

# Configuration: API Keys
DIGITALOCEAN_API_KEY_1="your_api_key_1"
DIGITALOCEAN_API_KEY_2="your_api_key_2"
TELEGRAM_TOKEN="your_telegram_bot_token"
TELEGRAM_CHAT_ID="your_telegram_chat_id"

# Define an associative array for droplets and their corresponding API keys environment variables
declare -A droplets
droplets["droplet-id-1"]="DIGITALOCEAN_API_KEY_1"
droplets["droplet-id-2"]="DIGITALOCEAN_API_KEY_1"
droplets["droplet-id-3"]="DIGITALOCEAN_API_KEY_2"
droplets["droplet-id-4"]="DIGITALOCEAN_API_KEY_2"

# Logging configuration
LOG_FILE="/var/log/snapshot_manager.log"

# Function to add message
add_message() {
    MESSAGES+="$1\n"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to send Telegram message
send_telegram() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d chat_id=$TELEGRAM_CHAT_ID -d text="$message" >/dev/null
}

# Function to manage snapshots
manage_snapshots() {
    local droplet_id=$1
    local api_key_var=$2
    local api_key=${!api_key_var}

    # Authenticate doctl with the current API key
    DOCTL_ACCESS_TOKEN=$api_key doctl auth init -t $api_key 2>/dev/null
    if [ $? -ne 0 ]; then
        add_message "Failed to authenticate for droplet $droplet_id with API key $api_key_var"
        return 1
    fi

    # Take a snapshot
    local snapshot_name="$(date +%Y-%m-%d-%H-%M-%S)"
    doctl compute droplet-action snapshot "$droplet_id" --snapshot-name "$snapshot_name" --wait 2>/dev/null
    if [ $? -ne 0 ]; then
        add_message "Failed to create snapshot for droplet $droplet_id"
        return 2
    fi

    # Get list of snapshots for the droplet, sort by date, and delete all but the last two
    local snapshots=$(doctl compute snapshot list --resource droplet --format ID,Name --no-header | grep $droplet_id | sort -r | awk '{print $1}')
    local count=0

    for snapshot in $snapshots; do
        let count+=1
        if [ $count -gt 2 ]; then
            doctl compute snapshot delete "$snapshot" --force 2>/dev/null
            if [ $? -ne 0 ]; then
                add_message "Failed to delete snapshot $snapshot for droplet $droplet_id"
                continue
            fi
            add_message "Deleted snapshot $snapshot for droplet $droplet_id"
        fi
    done
}

# Parse options
VERBOSE=false
TELEGRAM=false

while getopts ":vt" opt; do
  case $opt in
    v) VERBOSE=true ;;
    t) TELEGRAM=true ;;
    \?) echo "Invalid option -$OPTARG" >&2 ;;
  esac
done

# Loop through all droplets and manage their snapshots
for droplet_id in "${!droplets[@]}"; do
    manage_snapshots $droplet_id ${droplets[$droplet_id]}
done

# Output or send messages
if $VERBOSE; then
    echo -e "$MESSAGES"
fi

if $TELEGRAM; then
    send_telegram "$MESSAGES"
fi
