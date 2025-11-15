#!/bin/bash

# Update sFlow collector IP on all devices
DEVICES="spine1 spine2 leaf1 leaf2 leaf3 leaf4 leaf5 leaf6 leaf7 leaf8"

for device in $DEVICES; do
    echo "Updating sFlow collector on $device..."
    docker exec "clab-evpn-clos2-$device" sr_cli << EOF
enter candidate
/system sflow collector 1 collector-address 172.21.21.1
commit now
EOF
done

echo "Done! All devices now sending sFlow to 172.21.21.1"
