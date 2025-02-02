# UDM-Pro BGP Configuration for Cilium

This guide outlines the steps to enable and configure BGP routing on your UDM-Pro device for integration with a Cilium-based Kubernetes cluster.

## Prerequisite

**Note:** FRRouting (FRR) was added to the UDM-Pro firmware in version 3.1.15. Ensure your device is running firmware version 3.1.15 or later to follow this guide.

## Step 0: Make a subnet

If you're using a subnet outside of your servers IP range, you need to create a dedicated subnet/vlan pair for it, otherwise UnifiOS will NAT your traffic and you'll loose the source IP

## Step 1: Enable the BGP Daemon

First, enable the BGP daemon by modifying the FRRouting (FRR) daemons configuration. Run the following command:

```bash
sed -i 's/bgpd=no/bgpd=yes/g' /etc/frr/daemons
```

This command changes the bgpd option from no to yes, activating the BGP daemon on your system.

## Step 2: Configure FRRouting

Next, you'll need to adjust the FRR configuration to define your BGP neighbors. This involves editing the /etc/frr/frr.conf file. Below is a template for the necessary changes. Remember to repeat the neighbor configuration blocks for each neighbor you have, rather than listing every neighbor in this template.

```conf
# FRRouting Configuration
#
# Log settings
log syslog informational

! BGP configuration starts here
hostname <UNIFI_HOSTNAME>
frr defaults traditional

router bgp 64513
no bgp ebgp-requires-policy
bgp router-id 10.1.1.1

# Neighbor configuration
# Repeat this block for each BGP neighbor
neighbor <NEIGHBOR_IP> remote-as <NEIGHBOR_AS>
neighbor <NEIGHBOR_IP> description <NEIGHBOR_DESCRIPTION>
neighbor <NEIGHBOR_IP> update-source <VLAN_BRIDGE>
neighbor <NEIGHBOR_IP> soft-reconfiguration inbound
#

# IPv4 unicast configuration
address-family ipv4 unicast
# Repeat this block for all neighbours
neighbor <NEIGHBOR_IP> next-hop-self
#
exit-address-family

maximum-path 1
line vty
```

Replace <NEIGHBOR_IP> with the IP address of each BGP neighbor and <NEIGHBOR_AS> with the respective AS (Autonomous System) number. Ensure to repeat the neighbor configuration block for each neighbor. <VLAN_BRIDGE> as the name suggest is the name of your vlan interface

## Step 3: Enable and Start the FRR Service

Finally, enable and start the FRR service to apply your configuration and activate BGP routing:

```bash
systemctl enable frr.service && systemctl start frr.service
```

This command ensures that FRR starts automatically on boot and immediately starts the service.

<hr />

Remember to verify your BGP connectivity and routing tables after completing these steps to ensure everything is configured correctly.
