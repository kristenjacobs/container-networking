# Overlay Network

An example of creating multiple L2 networks, one on each of the nodes. Each network contains
2 network namespaces (containers), connected via a bridge, and have different subnets. The 
containers are connected via an overlay network implemented with a tuntap device and a UDP
cnnection between hosts.

![Diagram](./diagram.jpg)

Create the 2 VMs (container-networking-1 and container-networking-2):

```
vagrant up
```

SSH to each node (VM) in turn, and run the setup script to create the network namespaces connected via a bridge: 

```
vagrant ssh container-networking-[12]
./setup.sh
```

To see the status of the interfaces/route tables within each of the nodes and the namespaces, run:

```
./status.sh
```

To test the connectivity between the containers within and node, and across nodes, run the following:

```
./test.sh
```
