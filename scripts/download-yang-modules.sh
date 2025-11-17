#!/bin/bash

# YANG Module Download Script
# This script downloads YANG modules from Nokia SR Linux devices via gNMI

echo "=========================================="
echo "YANG Module Download Script"
echo "=========================================="
echo ""

# Default credentials for containerlab SR Linux
USERNAME="admin"
PASSWORD="NokiaSrl1!"

# Output directory for YANG modules
YANG_DIR="yang-modules"
mkdir -p "$YANG_DIR"

# Pick one device to download from (they all have the same YANG modules)
DEVICE="leaf1"
PORT="57411"

echo "Downloading YANG modules from $DEVICE (localhost:$PORT)"
echo "Output directory: $YANG_DIR"
echo ""

# Check if gnmic is installed
if ! command -v gnmic &> /dev/null; then
    echo "ERROR: gnmic is not installed"
    echo "Install it with: bash -c \"\$(curl -sL https://get-gnmic.openconfig.net)\""
    exit 1
fi

# Get the list of supported models from capabilities
echo "Step 1: Getting capabilities to list supported YANG models..."
CAPABILITIES=$(gnmic -a localhost:$PORT \
    -u "$USERNAME" \
    -p "$PASSWORD" \
    --skip-verify \
    --timeout 10s \
    capabilities --format json 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "✗ Failed to retrieve capabilities from $DEVICE"
    exit 1
fi

# Extract model names (extract just the last part after the colon, which is the actual module name)
MODELS=$(echo "$CAPABILITIES" | jq -r '.["supported-models"][] | .name' 2>/dev/null | sed 's/.*://' | sort -u)

if [ -z "$MODELS" ]; then
    echo "✗ No YANG models found in capabilities response"
    exit 1
fi

echo "✓ Found $(echo "$MODELS" | wc -l) unique YANG models"
echo ""

# Download YANG modules using docker cp from the container filesystem
echo "Step 2: Downloading YANG modules from container filesystem..."
echo ""

MODEL_COUNT=0
SUCCESS_COUNT=0

for model in $MODELS; do
    MODEL_COUNT=$((MODEL_COUNT + 1))
    echo -n "[$MODEL_COUNT] Downloading $model.yang ... "
    
    OUTPUT_FILE="$YANG_DIR/${model}.yang"
    
    # For SR Linux, YANG modules are in subdirectories under /opt/srlinux/models/
    # Try to find the file in the container
    CONTAINER_NAME="clab-evpn-clos2-$DEVICE"
    
    # Find the YANG file in the container
    YANG_PATH=$(docker exec "$CONTAINER_NAME" find /opt/srlinux/models/ -name "${model}.yang" -type f 2>/dev/null | head -1)
    
    if [ -n "$YANG_PATH" ]; then
        # Copy the file from the container
        docker cp "$CONTAINER_NAME:$YANG_PATH" "$OUTPUT_FILE" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "✓"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            echo "✗ (copy failed)"
            rm -f "$OUTPUT_FILE" 2>/dev/null
        fi
    else
        echo "✗ (not found)"
    fi
done

echo ""
echo "=========================================="
echo "Download Summary"
echo "=========================================="
echo "Total models found: $MODEL_COUNT"
echo "Successfully downloaded: $SUCCESS_COUNT"
echo "Output directory: $YANG_DIR"
echo ""

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo "✓ YANG modules saved to $YANG_DIR/"
    ls -lh "$YANG_DIR" | tail -n +2 | head -10
    if [ $MODEL_COUNT -gt 10 ]; then
        echo "... and $((MODEL_COUNT - 10)) more files"
    fi
else
    echo "Note: SR Linux YANG modules may be in a different location."
    echo "Try accessing them directly from the container:"
    echo "  docker exec clab-evpn-clos2-$DEVICE ls /opt/srlinux/models/"
fi

echo ""
