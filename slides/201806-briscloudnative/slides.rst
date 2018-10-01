
.. image:: ../title-page.jpg
   :height: 600px

The aim
-------

The network needs to satisfy the following (Kubenetes) requirements:

* All containers can communicate with all other containers without NAT

* All nodes can communicate with all containers (and vice-versa) without NAT

* The IP that a container sees itself as is the same IP that others see it as

The plan
--------

To work our way from nothing, to a (flannel style) overlay network in 4 'easy' steps:

* Step 1: Single network namespace

* Step 2: Single node

* Step 3: Multi node

* Step 4: Overlay network 

.. image:: ../../1-network-namespace/diagram.jpg
   :height: 710px

Routing rules 101
-----------------

4 Types of routing rules (in order of preceedence):

1. Directly connected network, e.g. *10.0.0.0/24 eth1*

2. Static (manually added) routing rule, e.g. *10.0.0.0/24 via 10.0.0.1 eth0*

3. Dynamic (automatically added) routing rule, e.g. *10.0.0.0/24 via 10.0.0.1 eth0*

4. Default rule, e.g. *default via 10.0.0.1 eth0*

Within each of the above, the most specific CIDR range takes priority.

.. image:: ../../2-single-node/diagram.jpg
   :height: 710px

.. image:: ../../3-multi-node/diagram.jpg
   :height: 710px

.. image:: ../../4-overlay-network/diagram.jpg
   :height: 710px

.. image:: ../overlay.jpg
   :height: 710px

Putting it all together
-----------------------

1. *Flannel*
    * *host-gw*: Step 3.
    * *udp*: Step 4.
    * *vxlan*: Step 4, but implemented in the kernel => more efficient!
    * *awsvpc*: Sets routes in AWS.
    * *gce*: Sets routes in GCE.
    * Node->pod-subnet mapping stored in *etcd*.

2. *Calico*
    * No overlay for intra L2. Uses next-hop routing (step 3).
    * For inter L2 node comminucation, uses IPIP overlay.
    * Node->pod-subnet mappings distributed to nodes using BGP.

3. *Weave*
    * Similar to *Flannel*, i.e. uses *vxlan* overlay for connectivity.
    * No need for *etcd*. Node->pod-subnet mapping distrubuted to each node peer to peer.

.. image:: ../github.png
   :height: 710px

.. class:: center

Questions?
----------

.. image:: ../bear.jpg
   :height: 500px

.. image:: ../appendix-cidr.jpg
   :height: 710px

.. image:: ../appendix-l2vsl3.jpg
   :height: 710px

.. header::
    container networking from scratch
