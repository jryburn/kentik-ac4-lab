#!/bin/bash
# creating bond interface w/LACP
ip link add bond0 type bond mode 802.3ad
ip addr add 10.40.40.10/24 dev bond0
ip link set eth1 down 
ip link set eth2 down
ip link set eth1 master bond0
ip link set eth2 master bond0
ip link set eth1 up 
ip link set eth2 up  
ip link set bond0 up