#!/bin/bash

# Script to add SNMP port mappings to running containers
# This modifies the Docker container configuration without requiring a full redeploy

echo "=========================================="
echo "Adding SNMP Port Mappings to Containers"
echo "=========================================="
echo ""

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Error: This script must be run with sudo"
    exit 1
fi

# Array of devices with their SNMP port mappings
declare -A DEVICES=(
    ["spine1"]="16121"
    ["spine2"]="16122"
    ["leaf1"]="16111"
    ["leaf2"]="16112"
    ["leaf3"]="16113"
    ["leaf4"]="16114"
    ["leaf5"]="16115"
    ["leaf6"]="16116"
    ["leaf7"]="16117"
    ["leaf8"]="16118"
)

# Stop Docker daemon to modify container configs
echo "Stopping Docker daemon..."
systemctl stop docker

# Backup directory
BACKUP_DIR="/tmp/docker-container-backup-$(date +%s)"
mkdir -p "$BACKUP_DIR"
echo "Backup directory: $BACKUP_DIR"
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0

# Iterate through all devices
for device in "${!DEVICES[@]}"; do
    EXTERNAL_PORT="${DEVICES[$device]}"
    CONTAINER_NAME="clab-evpn-clos2-$device"
    
    echo "Processing $device ($CONTAINER_NAME)..."
    
    # Find container ID
    CONTAINER_ID=$(docker ps -aqf "name=^${CONTAINER_NAME}$")
    
    if [ -z "$CONTAINER_ID" ]; then
        echo "  ✗ Container not found"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi
    
    # Path to container config
    CONFIG_PATH="/var/lib/docker/containers/${CONTAINER_ID}/config.v2.json"
    HOSTCONFIG_PATH="/var/lib/docker/containers/${CONTAINER_ID}/hostconfig.json"
    
    if [ ! -f "$CONFIG_PATH" ]; then
        echo "  ✗ Config file not found"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi
    
    # Backup original configs
    cp "$CONFIG_PATH" "$BACKUP_DIR/config.v2.json.${device}"
    cp "$HOSTCONFIG_PATH" "$BACKUP_DIR/hostconfig.json.${device}"
    
    # Add port binding to hostconfig.json
    # This adds: "161/udp": [{"HostIp": "", "HostPort": "16111"}]
    jq --arg port "$EXTERNAL_PORT" \
       '.PortBindings["161/udp"] = [{"HostIp": "", "HostPort": $port}]' \
       "$HOSTCONFIG_PATH" > "$HOSTCONFIG_PATH.tmp" && \
       mv "$HOSTCONFIG_PATH.tmp" "$HOSTCONFIG_PATH"
    
    if [ $? -eq 0 ]; then
        echo "  ✓ Added SNMP port mapping: localhost:$EXTERNAL_PORT -> 161/udp"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "  ✗ Failed to modify configuration"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        # Restore backup
        cp "$BACKUP_DIR/hostconfig.json.${device}" "$HOSTCONFIG_PATH"
    fi
done

echo ""
echo "=========================================="
echo "Starting Docker daemon..."
systemctl start docker

# Wait for Docker to start
echo "Waiting for Docker to be ready..."
sleep 5

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Successfully modified: $SUCCESS_COUNT containers"
echo "Failed: $FAIL_COUNT containers"
echo "Backup location: $BACKUP_DIR"
echo ""

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo "✓ SNMP port mappings added!"
    echo ""
    echo "Test with:"
    echo "  snmpwalk -v2c -c kentik123 localhost:16111 system"
    echo ""
    echo "Note: You may need to restart the containers for changes to take effect:"
    echo "  sudo docker restart clab-evpn-clos2-leaf1 clab-evpn-clos2-leaf2 ..."
fi

echo ""
