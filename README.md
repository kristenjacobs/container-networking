# Containers From Scratch

An example of creating linux network namespaces, connected via a bridge.

Creates the 2 VMs (containers-from-scratch-1 and containers-from-scratch-2:

```
vagrant up
```

SSH to each node (VM) in turn, and run the setup script to create the network namespaces connected via bridge: 

```
vagrant ssh containers-from-scratch-[12]
cd /vagrant
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

## References

https://blog.scottlowe.org/2013/09/04/introducing-linux-network-namespaces/
