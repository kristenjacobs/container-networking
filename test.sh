#!/bin/bash

CON1="con1"
CON2="con2"

if [ $(hostname) == "containers-from-scratch-1" ]; then 
    FROM_NODE_IP="10.0.0.10"
    FROM_IP1="10.0.0.11"
    FROM_IP2="10.0.0.12"
    TO_NODE_IP="10.0.0.20"
    TO_IP1="10.0.0.21"
    TO_IP2="10.0.0.22"
else
    FROM_NODE_IP="10.0.0.20"
    FROM_IP1="10.0.0.21"
    FROM_IP2="10.0.0.22"
    TO_NODE_IP="10.0.0.10"
    TO_IP1="10.0.0.11"
    TO_IP2="10.0.0.12"
fi

function check_error {
    if [ "$?" -ne 0 ]; then
        echo " - ***** FAILED *****"
    else
        echo " - PASSED"
    fi
}

echo -n "Checking connectivity from node $FROM_NODE_IP to node $FROM_NODE_IP"
ping -c 1 $FROM_NODE_IP > /dev/null
check_error

echo -n "Checking connectivity from node $FROM_NODE_IP to node $TO_NODE_IP"
ping -c 1 $TO_NODE_IP > /dev/null
check_error

# ----- #

echo -n "Checking connectivity from $CON1, $FROM_IP1 to node $FROM_NODE_IP"
sudo ip netns exec $CON1 ping -c 1 $TO_NODE_IP > /dev/null
check_error

echo -n "Checking connectivity from $CON1, $FROM_IP1 to node $TO_NODE_IP"
sudo ip netns exec $CON1 ping -c 1 $TO_NODE_IP > /dev/null
check_error

echo -n "Checking connectivity from $CON1, $FROM_IP1 to $CON1, $FROM_IP1"
sudo ip netns exec $CON1 ping -c 1 $FROM_IP1 > /dev/null
check_error

echo -n "Checking connectivity from $CON1, $FROM_IP1 to $CON1, $FROM_IP2"
sudo ip netns exec $CON1 ping -c 1 $FROM_IP2 > /dev/null
check_error

echo -n "Checking connectivity from $CON1, $FROM_IP1 to node $TO_NODE_IP"
sudo ip netns exec $CON1 ping -c 1 $TO_NODE_IP > /dev/null
check_error

echo -n "Checking connectivity from $CON1, $FROM_IP1 to $CON1, $TO_IP1"
sudo ip netns exec $CON1 ping -c 1 $TO_IP1 > /dev/null
check_error

echo -n "Checking connectivity from $CON1, $FROM_IP1 to $CON1, $TO_IP2"
sudo ip netns exec $CON1 ping -c 1 $TO_IP2 > /dev/null
check_error

# ----- #

echo -n "Checking connectivity from $CON2, $FROM_IP2 to node $FROM_NODE_IP"
sudo ip netns exec $CON2 ping -c 1 $TO_NODE_IP > /dev/null
check_error

echo -n "Checking connectivity from $CON2, $FROM_IP2 to node $TO_NODE_IP"
sudo ip netns exec $CON2 ping -c 1 $TO_NODE_IP > /dev/null
check_error

echo -n "Checking connectivity from $CON2, $FROM_IP2 to $CON2, $FROM_IP1"
sudo ip netns exec $CON2 ping -c 1 $FROM_IP2 > /dev/null
check_error

echo -n "Checking connectivity from $CON2, $FROM_IP2 to $CON2, $FROM_IP2"
sudo ip netns exec $CON2 ping -c 1 $FROM_IP2 > /dev/null
check_error

echo -n "Checking connectivity from $CON2, $FROM_IP2 to node $TO_NODE_IP"
sudo ip netns exec $CON2 ping -c 1 $TO_NODE_IP > /dev/null
check_error

echo -n "Checking connectivity from $CON2, $FROM_IP2 to $CON2, $TO_IP1"
sudo ip netns exec $CON2 ping -c 1 $TO_IP1 > /dev/null
check_error

echo -n "Checking connectivity from $CON2, $FROM_IP2 to $CON2, $TO_IP2"
sudo ip netns exec $CON2 ping -c 1 $TO_IP2 > /dev/null
check_error
