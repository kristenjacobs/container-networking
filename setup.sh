#!/bin/bash -e 

. env.sh

echo "Creating the namespaces"
sudo ip netns add $CON1
sudo ip netns add $CON2

echo "Creating the veth pairs"
sudo ip link add vethcon10 type veth peer name vethcon11
sudo ip link add vethcon20 type veth peer name vethcon21

echo "Adding the veth pairs to the namespaces"
sudo ip link set vethcon11 netns $CON1
sudo ip link set vethcon21 netns $CON2

echo "Configuring the interfaces in the containers with IP address"
sudo ip netns exec $CON1 ip addr add $IP1/24 dev vethcon11 
sudo ip netns exec $CON2 ip addr add $IP2/24 dev vethcon21 

echo "Enabling the interfaces inside the containers"
sudo ip netns exec $CON1 ip link set dev vethcon11 up
sudo ip netns exec $CON2 ip link set dev vethcon21 up

echo "Creating the bridge"
sudo ip link add name br0 type bridge

echo "Adding the containers interfaces to the bridge"
sudo ip link set dev vethcon10 master br0
sudo ip link set dev vethcon20 master br0

echo "Adding the nodes interface to the bridge"
sudo ip link set dev enp0s8 master br0

echo "Removing IP address from enp0s8"
sudo ip addr del $NODE_IP dev enp0s8

echo "Assigning the nodes IP address to the bridge"
sudo ip addr add $NODE_IP/32 dev br0

echo "Enabling the bridge"
sudo ip link set dev br0 up

echo "Enabling the interfaces connected to the bridge"
sudo ip link set dev vethcon10 up
sudo ip link set dev vethcon20 up

echo "Setting the loopback interfaces in the containers"
sudo ip netns exec $CON1 ip link set lo up
sudo ip netns exec $CON2 ip link set lo up

echo "Setting the routes on the node"
sudo ip route add 10.0.0.0/24 dev br0 src $NODE_IP
