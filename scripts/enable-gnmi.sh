#!/bin/bash

# Enable gNMI on all SR Linux devices
# This script configures the gnmi-server on all devices after deployment

echo "Enabling gNMI server on all devices..."
echo ""

DEVICES=(
    "clab-evpn-clos2-spine1"
    "clab-evpn-clos2-spine2"
    "clab-evpn-clos2-leaf1"
    "clab-evpn-clos2-leaf2"
    "clab-evpn-clos2-leaf3"
    "clab-evpn-clos2-leaf4"
    "clab-evpn-clos2-leaf5"
    "clab-evpn-clos2-leaf6"
    "clab-evpn-clos2-leaf7"
    "clab-evpn-clos2-leaf8"
)

for device in "${DEVICES[@]}"; do
    echo "Configuring $device..."
    docker exec -i "$device" bash -c "sr_cli <<EOF
enter candidate
/ system grpc-server admin-state enable
/ system grpc-server rate-limit 65000
/ system grpc-server unix-socket admin-state enable
/ system grpc-server trace-options [ common request response ]
commit now
EOF
"
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully configured $device"
    else
        echo "✗ Failed to configure $device"
    fi
    echo ""
done

echo "gNMI configuration complete!"
echo "Waiting 5 seconds for services to start..."
sleep 5
