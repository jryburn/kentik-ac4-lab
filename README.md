# L2 + L3 EVPN Multi-homing Lab

This lab sets up a pre-configured SR Linux-based fabric that forms the basis of the lab used for Kentik's Autocon4 workshop.

# Topology

The topology comprises two spine switches, eight leaf switches, and four Alpine Linux hosts. Each host is mulit-homed to two different leaf switches. Hosts 1 & 3 are connected via an L2 EVPN and have IP addresses in the same subnet. Hosts 2 & 4 are connected via an L3 EVPN. They have IP addresses in different subnets but can route to one another through the fabric.

TODO: Create a diagram to insert here

## Lab deployment

This lab is powered by containerlab and can be deployed on any Linux VM with enough resources. For the workshop, it runs on a Ubuntu VM with 8vCPUs and 32GB of RAM hosted by Instruqt. However, you could easily provision a VM anywhere and load this topology.

This lab comes with pre-configurations for each of the switches and hosts.

The topology and pre-configurations are defined in the containerlab topology file.

The SR Linux configurations are referred to as [config files](configs) (.cfg), and Alpine Linux configurations are defined in the [topology file](evpn-mh.clab.yml) to be directly executed at the deployment.

The SR Linux configurations are under the 'configs' folder.

Clone this repository to your Linux machine:

```bash
git clone https://github.com/jryburn/kentik-ac4-lab.git && cd kentik-ac4-lab
```

and deploy with containerlab:

```bash
containerlab deploy -t kentik-ac4-lab/srl-evpn-clos2.clab.yml
```
TODO: Copy/paste the output of the deploy command here.

When containerlab finishes the deployment it provides a summary table that outlines connection details of the deployed nodes. In the "Name" column we have the names of the deployed containers and those names can be used to reach the nodes, for example to connect to the SSH of `leaf1`:

# default credentials admin:NokiaSrl1!

```bash
ssh admin@kentik-ac4-lab-leaf1
```

To connect Alpine Linux (hosts):

```bash
docker exec -it kentik-ac4-lab-host1 bash
```

## Verify pre-configurations

Check the fabric configurations:

```bash
A:spine1# show network-instance default protocols bgp neighbor
```
```bash
A:spine2# show network-instance default protocols bgp neighbor
```

```bash
A:leaf1# info network-instance default
```

```bash
A:leaf1# info network-instance mac-vrf-1
```

Check the host interfaces:

```bash
bash-5.0# ip address
```
