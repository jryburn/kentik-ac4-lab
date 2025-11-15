#!/bin/bash

# gNMI Capabilities Check Script
# This script connects to all devices in the lab and retrieves their gNMI capabilities

echo "=========================================="
echo "gNMI Capabilities Check"
echo "=========================================="
echo ""

# Default credentials for containerlab SR Linux
USERNAME="admin"
PASSWORD="NokiaSrl1!"

# Array of devices with their management IPs
declare -A DEVICES=(
    ["spine1"]="172.21.21.21"
    ["spine2"]="172.21.21.22"
    ["leaf1"]="172.21.21.11"
    ["leaf2"]="172.21.21.12"
    ["leaf3"]="172.21.21.13"
    ["leaf4"]="172.21.21.14"
    ["leaf5"]="172.21.21.15"
    ["leaf6"]="172.21.21.16"
    ["leaf7"]="172.21.21.17"
    ["leaf8"]="172.21.21.18"
)

# Check if gnmic is installed
if ! command -v gnmic &> /dev/null; then
    echo "ERROR: gnmic is not installed"
    echo "Install it with: bash -c \"\$(curl -sL https://get-gnmic.openconfig.net)\""
    exit 1
fi

# Function to check capabilities for a device
check_capabilities() {
    local device=$1
    local ip=$2
    
    echo "----------------------------------------"
    echo "Device: $device ($ip)"
    echo "----------------------------------------"
    
    # Connect to gNMI via TCP from inside the container (port 57411 is the insecure gRPC port)
    docker exec "clab-evpn-clos2-$device" gnmic -a 127.0.0.1:57411 \
        -u "$USERNAME" \
        -p "$PASSWORD" \
        --insecure \
        --timeout 10s \
        capabilities
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully retrieved capabilities from $device"
    else
        echo "✗ Failed to retrieve capabilities from $device"
    fi
    echo ""
}

# Iterate through all devices
for device in "${!DEVICES[@]}"; do
    check_capabilities "$device" "${DEVICES[$device]}"
done

echo "=========================================="
echo "Capabilities check complete"
echo "=========================================="
