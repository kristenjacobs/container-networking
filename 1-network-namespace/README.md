# Network Namespace

An example of creating a simple network namespace connected
to the host via a veth pair.

![Diagram](./diagram.jpg)

Create the VM:

```
vagrant up
```

SSH to the VM and run the setup script to create the network namespace and the veth pair: 

```
vagrant ssh
cd /vagrant
./setup.sh
```

To see the status of the interfaces/route tables within the node and the namespace, run:

```
./status.sh
```

To test the connectivity between the node and the namespace, run the following:

```
./test.sh
```
