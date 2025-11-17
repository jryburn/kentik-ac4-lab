#!/bin/bash
# creating bond interface w/LACP
ip link add bond0 type bond mode 802.3ad
ip link set eth1 down 
ip link set eth2 down
ip link set eth1 master bond0
ip link set eth2 master bond0
ip link set eth1 up 
ip link set eth2 up  
ip link set bond0 up
ip link add link bond0 name bond0.34 type vlan id 34
ip link set bond0.34 up
ip addr add 10.34.34.34/24 dev bond0.34
ip route add 10.78.78.0/24 via 10.34.34.1

# Install iperf3 and start server, then run continuous tests to host1
apk add --no-cache iperf3
iperf3 -s -D

# Run iperf3 tests every 30 seconds continuously
(while true; do
  sleep 30
  iperf3 -c 10.78.78.78 -t 10 -i 5
done) &