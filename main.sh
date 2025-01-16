#!/bin/sh
set -e

transmission_username="${TRANSMISSION_USERNAME:-transmission}"
transmission_password="${TRANSMISSION_PASSWORD:-transmission}" # Default credentials
transmission_addr="${TRANSMISSION_ADDR:-http://localhost:9091}" # ex. http://10.0.1.48:9091
rpc_url="$transmission_addr/transmission/rpc"
gtn_addr="${GTN_ADDR:-http://localhost:8000}" # ex. http://10.0.1.48:8000

# Get the forwarded port from Gluetun
port_number=$(curl --fail --silent --show-error $gtn_addr/v1/openvpn/portforwarded | jq '.port')
if [ ! "$port_number" ] || [ "$port_number" = "0" ]; then
    echo "Could not get current forwarded port from Gluetun, exiting..."
    exit 1
fi

# Authenticate with Transmission and get the session ID
session_id=$(curl --silent --head --request POST $rpc_url | grep -o 'X-Transmission-Session-Id: .*' | awk -F': ' '{print $2}' | tr -d '\r')

# Get the current listening port from Transmission
current_port=$(curl --fail --silent --show-error \
    --header "X-Transmission-Session-Id: $session_id" \
    --user "$transmission_username:$transmission_password" \
    --data '{"method": "session-get"}' \
    "$rpc_url" | jq '.arguments["peer-port"]')

if [ ! "$current_port" ]; then
    echo "Could not get current listening port from Transmission, exiting..."
    exit 1
fi

# Check if the ports are the same
if [ "$port_number" = "$current_port" ]; then
    echo "Port already set, exiting..."
    exit 0
fi

# Update the listening port in Transmission
response=$(curl --fail --silent --show-error \
    --header "X-Transmission-Session-Id: $session_id" \
    --user "$transmission_username:$transmission_password" \
    --data "{\"method\": \"session-set\", \"arguments\": {\"peer-port\": $port_number}}" \
    $rpc_url)

if echo "$response" | grep -q 'success'; then
    echo "Successfully updated port to $port_number"
    exit 0
else
    echo "Failed to update port, exiting..."
    exit 1
fi
