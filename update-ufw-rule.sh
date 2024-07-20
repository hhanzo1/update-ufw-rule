#!/bin/bash
#
## Update ufw SSH 22/tcp Rule
#
# Run this script on your remote VPS and schedule via cron
#
#  Performs a DNS lookup
#  Compare previous/current IP
#  Update ufw rule if changed
#  Send ntfy notification
#
# run every day
# 0 * * * * /home/[USERID]/update-ufw-rule.sh
#

# Define your DNS hostname
DNS_HOSTNAME=""

# Define ntfy settings
NTFY_AUTH_TOKEN=""
NTFY_TOPIC=""
NTFY_MESSAGE_SUCCESS="ssh rule updated successfully for IP"
NTFY_MESSAGE_FAILURE="ssh rule failed to update"
NTFY_MESSAGE_NO_CHANGE="IP has not changed, no update needed"
NTFY_MESSAGE_SUCCESS_TAG="green_circle,white_check_mark,ufw,ssh"
NTFY_MESSAGE_FAILURE_TAG="red_circle,ufw,ssh"
NTFY_MESSAGE_NO_CHANGE_TAG="green_circle,ufw,ssh"

# File to store the last known IP address
LAST_IP_FILE="/var/tmp/last_ssh_ip.txt"

# Function to get the current public IP address from DNS lookup
get_current_ip() {
    dig +short $DNS_HOSTNAME
}

# Function to send success ntfy notification
send_ntfy_success_notification() {
    local message=$1
    ntfy publish --token "$NTFY_AUTH_TOKEN" --tags="$NTFY_MESSAGE_SUCCESS_TAG" "ntfy.sh/$NTFY_TOPIC" "$message"
}

# Function to send failure ntfy notification
send_ntfy_failure_notification() {
    local message=$1
    ntfy publish --token "$NTFY_AUTH_TOKEN" --tags="$NTFY_MESSAGE_FAILURE_TAG" "ntfy.sh/$NTFY_TOPIC" "$message"
}

# Function to send no change ntfy notification
send_ntfy_no_change_notification() {
    local message=$1
    ntfy publish --token "$NTFY_AUTH_TOKEN" --tags="$NTFY_MESSAGE_NO_CHANGE_TAG" "ntfy.sh/$NTFY_TOPIC" "$message"
}

# Get the current IP address
CURRENT_IP=$(get_current_ip)

# Check if the IP was retrieved successfully
if [ -z "$CURRENT_IP" ]; then
    echo "Failed to retrieve the current IP address from DNS."
    send_ntfy_failure_notification "$NTFY_MESSAGE_FAILURE: DNS lookup failed."
    exit 1
fi

# Check if the last IP file exists and read the last known IP
if [ -f "$LAST_IP_FILE" ]; then
    LAST_IP=$(cat "$LAST_IP_FILE")
else
    LAST_IP=""
fi

# Compare the current IP with the last known IP
if [ "$CURRENT_IP" == "$LAST_IP" ]; then
    echo "IP address has not changed, no update needed."
    send_ntfy_no_change_notification "$NTFY_MESSAGE_NO_CHANGE"
    exit 0
fi

# Define the rule you want to update (e.g., allow SSH from your home IP)
RULE="allow from $CURRENT_IP to any port 22"

# Update UFW rules
echo "Updating UFW rules to allow SSH from $CURRENT_IP..."

# Remove old rules for port 22 (optional, to avoid duplicates)
ufw delete allow 22/tcp

# Add the new rule
ufw allow from $CURRENT_IP to any port 22 proto tcp comment 'Allow SSH'

# Reload UFW to apply changes
ufw reload

# Save the current IP to the file
echo "$CURRENT_IP" > "$LAST_IP_FILE"

# Send ntfy success notification
send_ntfy_success_notification "$NTFY_MESSAGE_SUCCESS $CURRENT_IP"

echo "UFW rules updated successfully."