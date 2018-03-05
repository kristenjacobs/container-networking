#!/bin/bash -e 

CON1="con1"
CON2="con2"
HOSTIP="10.0.0.10"
IP1="10.0.0.11"
IP2="10.0.0.12"

echo "Installing the dependencies"
sudo apt-get update
sudo apt-get install -y bridge-utils
sudo apt-get install -y arping

echo "Creating the namespaces"
sudo ip netns add $CON1
sudo ip netns add $CON2

echo "Creating the veth pairs"
sudo ip link add vethcon10 type veth peer name vethcon11
sudo ip link add vethcon20 type veth peer name vethcon21

echo "Adding the veth pairs to the namespaces"
sudo ip link set vethcon11 netns $CON1
sudo ip link set vethcon21 netns $CON2

echo "Configuring the interfaces in the containers with IP address, and enabling them"
sudo ip netns exec $CON1 ifconfig vethcon11 $IP1/24 up
sudo ip netns exec $CON2 ifconfig vethcon21 $IP2/24 up

echo "Creating the bridge"
sudo brctl addbr br0

echo "Adding the containers interfaces to the bridge"
sudo brctl addif br0 vethcon10
sudo brctl addif br0 vethcon20

echo "Adding the host interface to the bridge"
sudo brctl addif br0 enp0s8

echo "Removing IP address from enp0s8"
sudo ifconfig enp0s8 0.0.0.0

echo "Enabling the bridge, and assigning it the hosts original IP address"
sudo ifconfig br0 $HOSTIP up

echo "Enabling the interfaces connected to the bridge"
sudo ifconfig vethcon10 up
sudo ifconfig vethcon20 up

echo "Setting the loopback interfaces in the containers"
sudo ip netns exec $CON1 ip link set lo up
sudo ip netns exec $CON2 ip link set lo up
