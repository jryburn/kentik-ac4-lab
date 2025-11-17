#!/bin/bash

# Update sFlow collector IP on all devices using gnmic
DEVICES="spine1 spine2 leaf1 leaf2 leaf3 leaf4 leaf5 leaf6 leaf7 leaf8"
USERNAME="admin"
PASSWORD="NokiaSrl1!"

for device in $DEVICES; do
    echo "Updating sFlow collector on $device..."
    docker exec "clab-evpn-clos2-$device" gnmic -a 127.0.0.1:57411 \
        -u "$USERNAME" -p "$PASSWORD" --insecure \
        set --update-path "/system/sflow/collector[collector-id=1]/collector-address" \
        --update-value "172.20.20.1"
done

echo "Done! All devices now sending sFlow to 172.20.20.1"