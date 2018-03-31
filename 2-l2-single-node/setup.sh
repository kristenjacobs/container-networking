#!/bin/bash -e 

. env.sh

echo "Creating the namespaces"
sudo ip netns add $CON1
sudo ip netns add $CON2

echo "Creating the veth pairs"
sudo ip link add veth10 type veth peer name veth11
sudo ip link add veth20 type veth peer name veth21

echo "Adding the veth pairs to the namespaces"
sudo ip link set veth11 netns $CON1
sudo ip link set veth21 netns $CON2

echo "Configuring the interfaces in the containers with IP address"
sudo ip netns exec $CON1 ip addr add $IP1/24 dev veth11 
sudo ip netns exec $CON2 ip addr add $IP2/24 dev veth21 

echo "Enabling the interfaces inside the containers"
sudo ip netns exec $CON1 ip link set dev veth11 up
sudo ip netns exec $CON2 ip link set dev veth21 up

echo "Creating the bridge"
sudo ip link add name br0 type bridge

echo "Adding the containers interfaces to the bridge"
sudo ip link set dev veth10 master br0
sudo ip link set dev veth20 master br0

echo "Enabling the bridge"
sudo ip link set dev br0 up

echo "Enabling the interfaces connected to the bridge"
sudo ip link set dev veth10 up
sudo ip link set dev veth20 up

echo "Setting the loopback interfaces in the containers"
sudo ip netns exec $CON1 ip link set lo up
sudo ip netns exec $CON2 ip link set lo up

echo "Setting the routes on the node"
sudo ip route del 10.0.0.0/24 dev enp0s3 src $NODE_IP
sudo ip route add 10.0.0.0/24 dev br0 src $NODE_IP
