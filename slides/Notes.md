# Container Networking Talk Notes

## Preparation

* Make sure all the vagrant environments are up and running and clean.
* Use VIM (or something that does coloured highlighting) to show scripts.

## Intro

* Motivation. Why am I doing this?
* Prerequsites. Aiming to describe *container* mnetworking from scratch. However,
  some networking concepts such as L2 vs. L3, subnets, CIDR ranges are assumed.
  I'll try my best to briefly describe these as we go..
* No expert though. Ask questions!

## Aim

* Aim to model the Kubernetes model.
* Contrast this with docker approach.

## Plan

* Summarise the 4 steps.
* Summarise the demo setup, i.e. using pre-prepared/up vagrant environments.

## Step 1: Diagram

* Describe the outer box (the node). Could be a physical machine, or a VM as in this case.
* Describe containers vs namespaces:
    * What is a container:
         * Namespaces: What a process can see
         * Cgroups: What a process can do.
         * Apparmour/secconf/capabilities: What a process has access to. 
    * What is a network namespace:
        * It's own network stack containing: 
            * It's own interfaces.
            * It's own routing + route tables.
            * It's own IPtables rules.
* Describe veth pair: Ethernet cable with NIC on each end.
* Describe the relevant routing from/to the network namespace.

## Step 1: Routing Rules (slide)

* 4 types of routing table entries:
    1. Directly connected networks (send to given interface)
    2. Static routing rules (send to given interface via given router)
    3. Dynamic routing rules (send to given interface via given router)
    4. Default gateway.
* Within each type, if overlapping, give precedence to the most specific CIDR range.

## Step 1: Demo

* Explain that we are running in a single node vagrant setup.
* Talk through the *env.sh*.
* Talk through the *setup.sh*.
    * Talk about IP tool.
    * Describe each setup line.
* Run the *setup.sh* script. 
* Show the interfaces/routes on the node.
* Show the interfaces/routes in the network namespace.
* Ping network namespace from node.
* Ping node from network namespace.
* What is actually responding to the pings in these cases? The network stack in the kernel.
* Show how we can run a real process in the network namespace (the python file server), and show curling this from the node.
* Explain that we can have multiple processes running inside a network namespace (e.g. in Kubernetes this corresponds to a pod).
* Start a 2nd python file server and curl this from the node.
* Show + run *test.sh*.

## Step 2: Diagram

* Describe the Linux bridge:
    * A single L2 broadcast domain, much like a switch, implemented in the kernel.
* The bridge now has its own subnet.
* The bridge also has its own IP: Allows access from the outside.
* Describe the route for the subnet.

## Step 2: Demo

* Explain that we now using a (new but similar) single node vagrant environment.
* Talk through the *env.sh*.
* Talk through the *setup.sh*.
    * Describe the parts common to the previous step.
    * Describe the bridge creation lines.
* Run the *setup.sh* script. 
* Show the interfaces/routes on the node.
* Show the interfaces/routes in the network namespace.
* Ping between network namespaces.
    * Highlight the TTL. Should be the default value, thus no routing is going on here!
* Ping network namespace from node.
    * Highlight the TTL. Should be the same.
* Mention that currently we cant get external traffic to the namespaces, as we are not fowarding IP packets. However, we will set this up in the next example.
* Show + run *test.sh*.

## Step 3: Diagram

* 2 nodes, each setup the same as 2 but with different subnets.
* Talk about the routing within the node. 
* Talk about the (next hop) routing between nodes (only works if the nodes are on the same L2 network). 
* Note that this is how the the *host-gw* flannel backend works, and also single L2 *Calico*.

## Step 3: Demo

* Explain that we are now using a 2 node vagrant setup.
* Talk through the *env.sh*.
* Talk through the *setup.sh*.
    * Describe the parts common to the previous step.
    * Describe the setup of the extra routes.
* Explain the IP forwarding.
    * What does this do/why is it needed: Turns your Linux box into a router.
    * Is enabling this a security risk: Maybe, but it is required in this case!
* Run the *setup.sh* script. 
* Show the interfaces/routes on the node.
* Show the interfaces/routes in the network namespace.
* Ping network namespaces across nodes.
    * Highlight the TTL. Explain the reported value.
* Ping a network namespace on the other node from the node.
    * Highlight the TTL. Explain the reported value.
* Show + run *test.sh*.

## Step 4: Diagram

* Now can't use static routes, as nodes could be on different subnets. Options:
    * Update routes on all routers in between (which can he done if you have control over the routers).
    * If running on cloud, then they typically provide an option to add routes (node-\>pod-subnet mappings) into your virtual network.
    * Another way us to use overlay network.
* Define an overlay network. A system such that processes can comunicate even though the routers in between don't know the where the processes actaully live.
* Introduce *tun/tap* devices. A network interface backed by a user-space process.
    * *tun* device accepts/outputs raw IP packets.  
    * *tap* device accepts/outputs raw ethernet packets.  
* How would we use it in this case.
* Now no need for the static routes.
* Talk about the routing for the overlay.
* This corresponds to the UDP backend for flannel (only recommended for debugging).
* For production, the *VXLAN* backend is recommended.

## Step 4: Demo

* Explain that we are now using a (new but similar) 2 node vagrant setup.
* Talk through the *env.sh* (same as previous step).
* Talk through the *setup.sh*.
    * Describe the parts common to the previous step.
    * Now no extra routes, but contains the socat implementation of the overlay.
* Describe *socat* in general.
* Describe how *socat* is being used here. 
* Describe how this is similar to a VPN.
* Run the *setup.sh* script. 
* Demo ping from network namespace to network namespace across nodes.
    * Highlight the TTL. Explain the reported value.
    * Show the *tshark* output from *eth0*, *tun0* and *br0* on the remote node.
* Demo ping from network namespace to remote node.
    * Highlight the TTL. Explain the reported value.
* Reverse packet filtering:
    * What is this: Discards incoming packets from interfaces where they shouldn't be.
    * It's purpose: A security feature to stop IP spoofed packets from being propagated.
    * Why we need the reverse packet filtering in this case?
    * Is it OK to turn this off? Again, maybe. Alternative is to ensure that packets from network namespaces to remote nodes also go via the overlay (which would involve src based routing!)
* Show + run *test.sh*.

## Conclusion

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

## End

...on this GitHub page.
