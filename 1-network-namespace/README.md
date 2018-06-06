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

To test the connectivity between the node and the namespace, run the following:

```
./test.sh
```

For an example of running a process inside of the network namespace, run the following:

```
sudo ip netns exec con python3 -m http.server 8000
```

This will run the Python simple HTTP file server. From the default network namespace,
it can be called as follows:

```
curl 10.0.0.11:8000
```
