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
ip link add link bond0 name bond0.78 type vlan id 78
ip link set bond0.78 up
ip addr add 10.78.78.78/24 dev bond0.78
ip route add 10.34.34.0/24 via 10.78.78.1