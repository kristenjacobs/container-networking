# Containers From Scratch

A simple example of creating linux network namespaces, connected via a bridge

Create the VM:

```
vagrant up
```

SSH to the VM:

```
vagrant ssh
cd /vagrant
```

To create 2 namespaces connected with a bridge:

```
./run.sh
```

To see the status of the interfaces/route tables within the VM and the namespaces:

```
./status.sh
```

From the VM, you should be able to ping the inteface in each of the namespaces:

```
ping 10.0.0.11
ping 10.0.0.12
```

Each of the namespaces should be able to ping each other and the VM:

```
sudo ip netns exec con1 bash
ping 10.0.0.10
ping 10.0.0.12
```

```
sudo ip netns exec con2 bash
ping 10.0.0.10
ping 10.0.0.11
```

## References

https://blog.scottlowe.org/2013/09/04/introducing-linux-network-namespaces/
