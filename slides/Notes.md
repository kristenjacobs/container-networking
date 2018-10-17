# Container Networking Talk Notes

* Motivation. Why am I doing this?
  Some time back I looked into updating the networking layer in the Oracle managed 
  networking service from using Flannel (an overlay network) to a solution which utilises
  the native networking features of the Orcale cloud (secondary VNICs + IPs). However, once
  I started digging in, I quickly found that I didnt understand the current solution...
   
* Prerequsites. Here I am aiming to describe *container* networking from scratch. 
  However, some networking concepts such as L2 vs. L3, subnets, CIDR ranges are assumed.
  I'll try my best to briefly describe these as we go..

* No expert though, i.e. at the end of this talk you'll know everythng I know about container networking!

## Slide: The aim

* Aim to model the Kubernetes model.
    * Each container (pod) has its own unique IP. 
    * No NAT'ing going on.
    * Host can talk to containers, and vice versa.

* Contrast this with the default docker approach.
    * i.e. only containers on a node have unique IP addresses.
    * Processes inside containers accessed via port mapping (IP tables). 

## Slide: The plan

* Summarise the 4 steps.

* Summarise the demo setup, i.e. using pre-prepared/up vagrant environments.

## Slide: Single network namespace diagram

* Describe the outer box (the node). Could be a physical machine, or a VM as in this case.

* Describe containers vs namespaces:
    * What is a container:
         * Cgroups: What a process can do. E.g:
             * Restrict memory
             * Restrict CPU
             * Restrict network bandwidth

         * Apparmour/secconf/capabilities: Security layer. E.g:
             * Restrict the system calls the contained process has access to.

         * Namespaces: What a process can see. E.g.
             * Mount namespace: Controls which parts of the file system the contained process can see.
             * Process namespace: Controls which other processes the contained process can see.
             * Network namespace: See below...

    * What is a network namespace:
        * It's own network stack containing: 
            * It's own interfaces.
            * It's own routing + route tables.
            * It's own IPtables rules.
        * When created, it is empty, i.e. no interfaces, routing or IP tables rules.

* Describe VETH pair: Ethernet cable with NIC on each end.
* Describe the relevant routing from/to the network namespace.

## Slide: Routing rules 101

The key 'aha' moment for for me in this whole process was understanding routing
rules, and their types, as this made routing in general 'click' into place.
Therefore if you take were to only take one thing form this talk, it should be
this.

* 4 types of routing table entries:
    1. Directly connected networks (send to given interface)
    2. Static routing rules (send to given interface via given router)
    3. Dynamic routing rules (send to given interface via given router)
    4. Default gateway.
* Within each type, if overlapping, give precedence to the most specific CIDR range.

## Code: Single network namespace setup.sh

* Explain that we are running in a single node vagrant setup.
* Talk through the *setup.sh*.
    * Talk about the *ip* tool.
    * Describe each setup line.

## Demo: Single network namespace

```
./setup.sh
# The interfaces + routes inside the network namespace
sudo ip netns exec con ip a
sudo ip netns exec con ip r
# The interfaces + routes on the node
ip a
ip r
# Pings the network namespace from the node
ping 176.16.0.1
# Pings the node from the network namespace
sudo ip netns exec con ping 10.0.0.10
```

* What is actually responding to the pings in these cases, as there is no process running 
  inside the namespace who can respond in this case?
  Do a quick dive into ICMP here. It is a layer 3(.5?) protocol, i.e. we have 
  an ICMP header inside of the IP packet, which defines a bunch of bits used in managing
  IP packetes. e.g.
     - Reporting that TTL has expired - More on this later...
     - Reporting that we need to fragment, but the DF bit is set - again, more on this later.
     - Bits for echo request and echo response (A.K.A ping).
  Therefore, in this case, it is the network stack in the kernel that is reponding to the 
  ICMP echo request packet, with a ICMP echo request packet.

For a more realistic example, We can run one (or more) real process in the network namespace 
(e.g. the python file server), and can the curl this from the node:

```
# Runs the python file server in the background on port 8000, inside the network namespace
sudo ip netns exec con python3 -m http.server 8000 &
# Curls the python file server from the node
curl 172.16.0.1:8000
```

Note: you can run multiple processes inside a network namespace, which roughly corresponds to a Kubernetes pod.

## Slide: Diagram of multiple network namespaces on the same node

* Describe the Linux bridge:
    * A single L2 broadcast domain, much like a switch, implemented in the kernel.
* The bridge now has its own subnet.
* The bridge also has its own IP: Allows access from the outside.
* Describe the route for the subnet.

## Code: Multiple network namespace setup.sh

* Explain that we now using a (new but similar) single node vagrant environment.
* Talk through the *setup.sh*.
    * Describe the parts common to the previous step.
    * Describe the bridge creation lines.

## Demo: Multiple network namespace

```
./setup.sh
# The interfaces + routes inside a network namespace
sudo ip netns exec con1 ip a
sudo ip netns exec con1 ip r
# The interfaces + routes on the node
ip a
ip r
# Pings between the network namespaces
sudo ip netns exec con1 ping 172.16.0.3
# Pings the node from the network namespace
sudo ip netns exec con1 ping 10.0.0.10
```

* When we ping between the network namespaces:
    * Highlight the TTL. Should be the default value, thus no routing is going on here!
    * Describe what the TTL is, and what happens when the TTL reaches zero.
    * Can also describe how the TTL is used, e.g. in the implementation of traceroute.
* When we ping network namespace from node:
    * Highlight the TTL. Should be the same.
* Mention that currently we cant get external traffic to the namespaces, as we are not fowarding IP packets. 
  However, we will set this up in the next example.

## Slide: Diagram of multiple network namespaces on different nodes but same subnet

* 2 nodes on the same subnet, each setup the same as 2 but with containing different network namespace subnets.
* Talk about the routing within the node. 
* Talk about the (next hop) routing between nodes (only works if the nodes are on the same L2 network). 
* Note that this is how the the *host-gw* flannel backend works, and also single L2 *Calico*.

## Code: Multi node setup.sh

* Explain that we are now using a 2 node vagrant setup.
* Talk through the *setup.sh*.
    * Describe the parts common to the previous step.
    * Describe the setup of the extra routes.
* Explain the IP forwarding.
    * What does this do/why is it needed: Turns your Linux box into a router.
    * Is enabling this a security risk: Maybe, but it is required in this case!

## Demo: Multi node

On each node, run:

```
./setup.sh
# The routes on the node
ip r
```

From 10.0.0.20:

```
# Captures ICMP packetes on the veth20 interface connected to the bridge
sudo tcpdump -ni veth10 icmp
```

Then from 10.0.0.10:

```
# Pings from a network namespaces on one node to one on the other node
sudo ip netns exec con1 ping 172.16.1.2
# Pings the same network namespace from the node
ping 172.16.1.2
```

* When we ping from a network namespaces to another network namespace across nodes:
    * Highlight the TTL. Explain the reported value.
* When we ping a network namespace on the other node from the node:
    * Highlight the TTL. Explain the reported value.

## Slide: Diagram of multiple network namespaces on different nodes on different subnets (the overlay network)

* Now can't use static routes, as nodes could be on different subnets. Options:
    * Update routes on all routers in between (which can he done if you have control over the routers).
    * If running on cloud, then they might provide an option to add routes (node-\>pod-subnet mappings) into your virtual network. For example, AWS (and Oracle cloud) both allow this.
    * Another way us to use overlay network.
* Define an overlay network. A system such that processes can comunicate even though the routers in between don't know the where the processes actaully live.
* Introduce *tun/tap* devices. A network interface backed by a user-space process.
    * *tun* device accepts/outputs raw IP packets.  
    * *tap* device accepts/outputs raw ethernet packets.  
* How would we use it in this case.
* Now no need for the static routes.

## Slide: Diagram of the route of a packet through the tun devicies

* Talk about the routing for the overlay.
* This corresponds to the UDP backend for flannel (only recommended for debugging).
* For production, the *VXLAN* backend is recommended.

## Code: Overlay network setup.sh

* Explain that we are now using a (new but similar) 2 node vagrant setup.
* Talk through the *setup.sh*. 
    * Describe the parts common to the previous step.
    * We need packet forwarding enabled here. This allows the node to act as a router, i.e.
      to accept and forward packets recieved, but no tdestined for, the IP of the node.
    * Now no extra routes, but contains the socat implementation of the overlay.
* Describe *socat* in general. It creates 2 bidirectiona bytestreams, and transfers data between them.
* Describe how *socat* is being used here. 
* Describe how this is similar to a VPN: How could we construct a virtual network
  between 2 hosts using socat (creating a VN!). For example, start the VN 'server' on the destination
  network using a tun device and the UDP tunnel. Start the VN 'client', with the same setup. Connect the UDP
  tunnel, then assign the tun device an address on the desination network. Just add encryption to this, and you'll
  have your very own VPN!
* Note the MTU settings, what is going on here? We reduce the MTU of the tun0 
  device as this allows for the 8 bytes UDP header that will be added, thus ensuring that 
  fragmentation does not occur.
* Describe the scheme that is used to ensure that the kernel chooses packet sizes that dont cause fragmentation
  (using the DF bit in the IP packets, and the 'Fragmentation required' ICMP response.
* Reverse packet filtering:
    * What is this: Discards incoming packets from interfaces where they shouldn't be.
    * It's purpose: A security feature to stop IP spoofed packets from being propagated.
    * Why we need the reverse packet filtering in this case?
    * Is it OK to turn this off? Again, maybe. Alternative is to ensure that packets from network 
      namespaces to remote nodes also go via the overlay (which would involve src based routing!)

## Demo: Overlay network

On each node, run:

```
./setup.sh
```

From 10.0.0.20:

```
# Captures ICMP packetes on the veth20 interface connected to the bridge
sudo tcpdump -ni veth10 icmp
```

From 10.0.0.10:

```
# Ping from a network namespaces on one node to one on the other node
sudo ip netns exec con1 ping 172.16.1.2
# Pings the same network namespace from the node
ping 172.16.1.2
```

* When we ping from a network namespace to a network namespace across nodes:
    * Highlight the TTL. Explain the reported value (should have decreased by 2).
* When we ping from a node to a remote network namespace:
    * Highlight the TTL. Explain the reported value (should have decreased by 1).

To see the encapsulation process more clearly:

On node 10.0.0.10:

```
# Pings from a local network namespace to a remote network namespace
./send.sh
```

Meanwhile, on node 10.0.0.20:

```
# Captures traffic on interface enp0s8
./capture.sh enp0s8
# Captures traffic on interface tun0
./capture.sh tun0
# Captures traffic on interface br0
./capture.sh br0
```

## Slide: Putting it all together

So how does this work in the real world?

* Need a way to map nodes to subnets. In Kubernetes, this could be Etcd.

* Popular network solutions:
    * 1. *Flannel* 
        * Uses *etcd* to store the node->pod-subnet mapping.
        * Multiple backends:
            * *host-gw*: step 3
            * *udp*: step 4
            * *VXLAN*: step 4, but more efficient. 
            * *awsvpc*: Sets routes in AWS.
    * 2. *Calico*
        * No overlay for intra L2. Uses next-hop routing (step 3).
        * For inter L2 node comminucation, uses IPIP overlay.
        * Node->pod-subnet mappings distributed to nodes using BGP.
    * 3. *Weave*
        * Similar to *Flannel*, uses *VXLAN* overlay for connectivity.
        * No need for *etcd*. Node->pod-subnet mapping distrubuted to each node via gossiping. 

## Slide: Github

All this is available on GitHub *kristenjacobs/container-networking*

## Slide: Questions?
