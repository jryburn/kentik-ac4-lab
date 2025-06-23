# L2 + L3 EVPN Multi-homing Lab

This lab sets up a pre-configured SR Linux-based fabric that forms the basis of the lab used for Kentik's Autocon4 workshop.

# Topology

The topology comprises two spine switches, eight leaf switches, and four Alpine Linux hosts. Each host is mulit-homed to two different leaf switches. Hosts 1 & 3 are connected via an L2 EVPN and have IP addresses in the same subnet. Hosts 2 & 4 are connected via an L3 EVPN. They have IP addresses in different subnets but can route to one another through the fabric.

!(images/srl-evpn-clos2.clab.drawio.svg)

## Lab deployment

This lab is powered by containerlab and can be deployed on any Linux VM with enough resources. For the workshop, it runs on a Ubuntu VM with 8vCPUs and 32GB of RAM hosted by Instruqt. However, you could easily provision a VM anywhere and load this topology.

This lab comes with pre-configurations for each of the switches and hosts.

The topology and pre-configurations are defined in the containerlab topology file.

The SR Linux configurations are referred to as [config files](configs) (.cfg), and Alpine Linux configurations are defined in [shell scripts](configs) to be directly executed at the deployment.

All configurations are under the 'configs' folder.

Clone this repository to your Linux machine:

```bash
git clone https://github.com/jryburn/kentik-ac4-lab.git && cd kentik-ac4-lab
```

and deploy with containerlab:

```bash
containerlab deploy -t srl-evpn-clos2.clab.yml
```

```bash
root@host:~/kentik-ac4-lab# containerlab deploy -t srl-evpn-clos2.clab.yml
14:15:04 INFO Containerlab started version=0.68.0
14:15:04 INFO Parsing & checking topology file=srl-evpn-clos2.clab.yml
14:15:04 INFO Creating docker network name=clab IPv4 subnet=172.20.20.0/24 IPv6 subnet=3fff:172:20:20::/64 MTU=1500
14:15:04 INFO Creating lab directory path=/root/kentik-ac4-lab/clab-evpn-clos2
14:15:04 INFO Creating container name=host1
14:15:04 INFO Creating container name=host3
14:15:04 INFO Creating container name=leaf8
14:15:04 INFO Creating container name=leaf6
14:15:04 INFO Creating container name=spine2
14:15:04 INFO Creating container name=leaf2
14:15:04 INFO Creating container name=leaf4
14:15:04 INFO Creating container name=leaf5
14:15:05 INFO Running postdeploy actions kind=srl node=leaf2
14:15:05 INFO Running postdeploy actions kind=srl node=leaf8
14:15:05 INFO Created link: leaf2:e1-9 ▪┄┄▪ spine2:e1-2
14:15:05 INFO Created link: leaf5:e1-7 ▪┄┄▪ host3:eth1
14:15:05 INFO Running postdeploy actions kind=srl node=leaf5
14:15:05 INFO Created link: leaf2:e1-7 ▪┄┄▪ host1:eth2
14:15:05 INFO Running postdeploy actions kind=srl node=leaf4
14:15:05 INFO Created link: leaf4:e1-9 ▪┄┄▪ spine2:e1-4
14:15:05 INFO Created link: leaf5:e1-9 ▪┄┄▪ spine2:e1-5
14:15:05 INFO Created link: leaf6:e1-7 ▪┄┄▪ host3:eth2
14:15:05 INFO Running postdeploy actions kind=srl node=leaf6
14:15:06 INFO Created link: leaf6:e1-9 ▪┄┄▪ spine2:e1-6
14:15:06 INFO Creating container name=leaf7
14:15:06 INFO Creating container name=host2
14:15:06 INFO Created link: leaf8:e1-9 ▪┄┄▪ spine2:e1-8
14:15:06 INFO Running postdeploy actions kind=srl node=spine2
14:15:07 INFO Created link: leaf7:e1-9 ▪┄┄▪ spine2:e1-7
14:15:07 INFO Running postdeploy actions kind=srl node=leaf7
14:15:07 INFO Created link: leaf4:e1-7 ▪┄┄▪ host2:eth2
14:15:07 INFO Creating container name=leaf1
14:15:08 INFO Created link: leaf1:e1-9 ▪┄┄▪ spine2:e1-1
14:15:08 INFO Created link: leaf1:e1-7 ▪┄┄▪ host1:eth1
14:15:08 INFO Running postdeploy actions kind=srl node=leaf1
14:16:07 INFO Creating container name=leaf3
14:16:07 INFO Created link: leaf3:e1-9 ▪┄┄▪ spine2:e1-3
14:16:07 INFO Created link: leaf3:e1-7 ▪┄┄▪ host2:eth1
14:16:07 INFO Running postdeploy actions kind=srl node=leaf3
14:16:10 INFO Creating container name=host4
14:16:11 INFO Created link: leaf7:e1-7 ▪┄┄▪ host4:eth1
14:16:11 INFO Created link: leaf8:e1-7 ▪┄┄▪ host4:eth2
14:16:11 INFO Creating container name=spine1
14:16:12 INFO Created link: leaf1:e1-8 ▪┄┄▪ spine1:e1-1
14:16:12 INFO Created link: leaf2:e1-8 ▪┄┄▪ spine1:e1-2
14:16:12 INFO Created link: leaf3:e1-8 ▪┄┄▪ spine1:e1-3
14:16:12 INFO Created link: leaf4:e1-8 ▪┄┄▪ spine1:e1-4
14:16:12 INFO Created link: leaf5:e1-8 ▪┄┄▪ spine1:e1-5
14:16:12 INFO Created link: leaf6:e1-8 ▪┄┄▪ spine1:e1-6
14:16:12 INFO Created link: leaf7:e1-8 ▪┄┄▪ spine1:e1-7
14:16:12 INFO Created link: leaf8:e1-8 ▪┄┄▪ spine1:e1-8
14:16:12 INFO Running postdeploy actions kind=srl node=spine1
14:16:47 INFO Executed command node=host3 command="bash /host3-config.sh" stdout=""
14:16:47 INFO Executed command node=host1 command="bash /host1-config.sh" stdout=""
14:16:47 INFO Executed command node=host2 command="bash /host2-config.sh" stdout=""
14:16:47 INFO Executed command node=host4 command="bash /host4-config.sh" stdout=""
14:16:47 INFO Adding host entries path=/etc/hosts
14:16:47 INFO Adding SSH config for nodes path=/etc/ssh/ssh_config.d/clab-evpn-clos2.conf
╭────────────────────────┬────────────────────────────────┬─────────┬───────────────────╮
│          Name          │           Kind/Image           │  State  │   IPv4/6 Address  │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-host1  │ linux                          │ running │ 172.20.20.7       │
│                        │ ghcr.io/srl-labs/alpine:latest │         │ 3fff:172:20:20::7 │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-host2  │ linux                          │ running │ 172.20.20.11      │
│                        │ ghcr.io/srl-labs/alpine:latest │         │ 3fff:172:20:20::b │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-host3  │ linux                          │ running │ 172.20.20.8       │
│                        │ ghcr.io/srl-labs/alpine:latest │         │ 3fff:172:20:20::8 │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-host4  │ linux                          │ running │ 172.20.20.14      │
│                        │ ghcr.io/srl-labs/alpine:latest │         │ 3fff:172:20:20::e │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-leaf1  │ srl                            │ running │ 172.20.20.12      │
│                        │ ghcr.io/nokia/srlinux:25.3.1   │         │ 3fff:172:20:20::c │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-leaf2  │ srl                            │ running │ 172.20.20.2       │
│                        │ ghcr.io/nokia/srlinux:25.3.1   │         │ 3fff:172:20:20::2 │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-leaf3  │ srl                            │ running │ 172.20.20.13      │
│                        │ ghcr.io/nokia/srlinux:25.3.1   │         │ 3fff:172:20:20::d │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-leaf4  │ srl                            │ running │ 172.20.20.6       │
│                        │ ghcr.io/nokia/srlinux:25.3.1   │         │ 3fff:172:20:20::6 │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-leaf5  │ srl                            │ running │ 172.20.20.5       │
│                        │ ghcr.io/nokia/srlinux:25.3.1   │         │ 3fff:172:20:20::5 │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-leaf6  │ srl                            │ running │ 172.20.20.9       │
│                        │ ghcr.io/nokia/srlinux:25.3.1   │         │ 3fff:172:20:20::9 │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-leaf7  │ srl                            │ running │ 172.20.20.10      │
│                        │ ghcr.io/nokia/srlinux:25.3.1   │         │ 3fff:172:20:20::a │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-leaf8  │ srl                            │ running │ 172.20.20.3       │
│                        │ ghcr.io/nokia/srlinux:25.3.1   │         │ 3fff:172:20:20::3 │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-spine1 │ srl                            │ running │ 172.20.20.15      │
│                        │ ghcr.io/nokia/srlinux:25.3.1   │         │ 3fff:172:20:20::f │
├────────────────────────┼────────────────────────────────┼─────────┼───────────────────┤
│ clab-evpn-clos2-spine2 │ srl                            │ running │ 172.20.20.4       │
│                        │ ghcr.io/nokia/srlinux:25.3.1   │         │ 3fff:172:20:20::4 │
╰────────────────────────┴────────────────────────────────┴─────────┴───────────────────╯
```

When containerlab finishes the deployment it provides a summary table that outlines connection details of the deployed nodes. In the "Name" column we have the names of the deployed containers and those names can be used to reach the nodes, for example to connect to the SSH of `leaf1`:

## Connect to the devices

**Default credentials admin:NokiaSrl1!**

To connect to the SR-L switches:

```bash
ssh admin@clab-evpn-clos2-leaf1
```

To connect Alpine Linux (hosts):

```bash
docker exec -it clab-evpn-clos2-host1 /bin/bash
```

## Verify pre-configurations

### Check the fabric configurations

On spine1:
```bash
show network-instance default protocols bgp neighbor
```

On spine2:
```bash
show network-instance default protocols bgp neighbor
```

On leaf1:
```bash
info network-instance default
```
```bash
info network-instance mac-vrf-1
```

### Check the host interfaces

On host1:
```bash
ip address
```
```bash
ping 10.40.40.30
```

On host2:
```bash
ip address
```
```bash
ping 10.78.78.78
```
