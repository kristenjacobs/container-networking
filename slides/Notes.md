# Container Networking Talk Notes

## Preparation

* Make sure all the vagrant environments are up and running and clean.
* Use VIM (or something that does coloured highlighting) to show scripts.

## Intro

* Motivation. Why am I doing this?
* No expert though. Ask questions!

## Aim

* Aim to model the Kubernetes model.
* Contrast this with docker approach.

## Plan

* Summarise the 4 steps.
* Summarise the demo setup, i.e. using pre-prepared/up vagrant environments.

# Step 1: Diagram

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
* Describe the relevant routing.

## Step 1: Routing Rules (slide)

* 4 types.
* Precedence within each type.

## Step 1: Demo

* Explain that we are running in a single node vagrant setup.
* Show the *env.sh*.
* Talk through the setup.sh.
    * Talk about IP tool.
    * Describe each setup line.
* Run the setup script. 
* Show the interfaces/routes on the node.
* Show the interfaces/routes in the network namespace.
* Ping network namespace from node.
* Ping node from network namespace.
* What is actually responding to the pings in these cases: The network stack in the kernel
* Show how we can run a real process in the network namespace (the python file server), and show curling this from the node.
* Explain that we can have multiple processes running inside a network namespace (i.e. in Kubernetes this corresponds to a pod).
* Start a 2nd python file server and curl this from the node.
* Show + run the test script.

## Step 2: Diagram

* Describe the Linux bridge:
    * A single L2 broadcast domain, much like a switch, implemented in the kernel.
* The bridge now has its own subnet.
* The bridge also has its own IP: Allows access from the outside.
* Describe the route for the subnet.

## Step 2: Demo

* Explain that we now using a (different) single node vagrant environment.
* Walk through bridge creation lines.
* Run setup script.
* Show routes on host.
* Show routes on network namespace.
* Ping between network namespaces.
    * Highlight the TTL. Should be the default value, thus no routing is going on here!
* Ping network namespace from node.
    * Highlight the TTL. Should be the same.
* Mention that currently we cant get external traffic to the namespaces, as we are not fowarding IP packets. However, we will set this up in the next example.
* Show + run the test script.

## Step 3: Diagram

* 2 nodes, each setup the same as 2 but with different subnets.
* Talk about the routing within the node. 
* Talk about the (next hop) routing between nodes (only works if the nodes are on the same L2 network). 
* This is how the the *host-gw* flannel backend works, and also single L2 *Calico*.

## Step 3: Demo

* Explain that we are now using a 2 node vagrant setup.
* Explain the setup of the extra routes.
* Explain the IP forwarding.
    * What does this do/why is it needed: Turns your Linux box into a router.
    * Is enabling this a security risk: Maybe, but it is required in this case!
* Run the setup.sh
* Show the host routes.
* Show the network namespace routes.
* Ping network namespaces across nodes.
    * Highlight the TTL. Explain the reported value.
* Ping a network namespace on the other node from this node.
    * Highlight the TTL. Explain the reported value.
* Show + run the test script.

## Step 4: Diagram

* Now can't use static routes, as nodes could be on different subnets.
    * One way is to update routes on all routers in between (which can he done)
    * Another way us to use overlay network.
* Define an overlay network. A system such that processes can comunicate even though the routers in between dont know the where the processes actaully live.
* Introduce tun/tap devices.
* How would we use it in this case.
* Now no need for the static routes.
* Talk about the routing for the overlay.
* This corresponds to the UDP backend for flannel (only recommended for debugging).
* For production, the *VXLAN* backend is recommended.

## Step 4: Demo

* Explain that we are now using a (different) 2 node vagrant setup.
* Setup script all the same.
* Describe *socat* in general.
* Describe how *socat* is being used here. 
* Describe how this is similar to a VPN.
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
* Show + run the test script.

## Conclusion

So how does this work in the real world?

* Need a way to map nodes to subnets. In Kubernetes, this could be Etcd.

* Popular network solutions:
    * 1. *Flannel* Multiple backends:
        * *host-gw*: step 3
        * *udp*: step 4
        * *vxlan*: step 4, but more efficient. 
        * *awsvpc*: Sets routes in AWS.
    * 2. *Calico*
        * TODO
    * 3. *Weave*
        * TODO

## End

...on this GitHub page.
