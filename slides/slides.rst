
.. image:: title-page.jpg
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

.. image:: ../1-network-namespace/diagram.jpg
   :height: 710px

Routing rules 101
-----------------

4 Types of routing rules (in order of preceedence):

1. Directly connected network, e.g. *10.0.0.0/24 eth1*

2. Static (manually added) routing rule, e.g. *10.0.0.0/24 via 10.0.0.1 eth0*

3. Dynamic (automatically added) routing rule, e.g. *10.0.0.0/24 via 10.0.0.1 eth0*

4. Default rule, e.g. *default via 10.0.0.1 eth0*

Within each of the above, the most specific CIDR range takes priority.

.. image:: ../2-single-node/diagram.jpg
   :height: 710px

.. image:: ../3-multi-node/diagram.jpg
   :height: 710px

.. image:: ../4-overlay-network/diagram.jpg
   :height: 710px

Links
-----

* https://github.com/kristenjacobs/container-networking

.. header::
    container networking from scratch
