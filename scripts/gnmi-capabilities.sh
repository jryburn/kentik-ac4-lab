#!/bin/bash

# gNMI Capabilities Check Script
# This script connects to all devices in the lab via exposed gNMI ports and retrieves their capabilities

echo "=========================================="
echo "gNMI Capabilities Check"
echo "=========================================="
echo ""

# Default credentials for containerlab SR Linux
USERNAME="admin"
PASSWORD="NokiaSrl1!"

# Array of devices with their exposed gNMI ports
declare -A DEVICES=(
    ["spine1"]="57421"
    ["spine2"]="57422"
    ["leaf1"]="57411"
    ["leaf2"]="57412"
    ["leaf3"]="57413"
    ["leaf4"]="57414"
    ["leaf5"]="57415"
    ["leaf6"]="57416"
    ["leaf7"]="57417"
    ["leaf8"]="57418"
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
    local port=$2
    
    echo "----------------------------------------"
    echo "Device: $device (localhost:$port)"
    echo "----------------------------------------"
    
    # Connect to gNMI via exposed port
    gnmic -a localhost:$port \
        -u "$USERNAME" \
        -p "$PASSWORD" \
        --skip-verify \
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
