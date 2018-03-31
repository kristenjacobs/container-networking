#!/bin/bash

. env.sh

function check_error {
    if [ "$?" -ne 0 ]; then
        echo " - ***** FAILED *****"
    else
        echo " - PASSED"
    fi
}

function check_connectivity_from_node {
    fromIP=$1
    toIP=$2
    echo -n "Checking connectivity from node $fromIP to $toIP"
    ping -W 1 -c 1 $toIP > /dev/null 2>&1
    check_error
}

function check_connectivity_from_container {
    ns=$1
    fromIP=$2
    toIP=$3
    echo -n "Checking connectivity from container $fromIP to $toIP"
    sudo ip netns exec $ns ping -W 1 -c 1 $toIP > /dev/null 2>&1
    check_error
}

check_connectivity_from_node $NODE_IP $NODE_IP
check_connectivity_from_node $NODE_IP $IP1
check_connectivity_from_node $NODE_IP $IP2
check_connectivity_from_container $CON1 $IP1 $NODE_IP
check_connectivity_from_container $CON1 $IP1 $IP1
check_connectivity_from_container $CON1 $IP1 $IP2
check_connectivity_from_container $CON2 $IP2 $NODE_IP
check_connectivity_from_container $CON2 $IP2 $IP1
check_connectivity_from_container $CON2 $IP2 $IP2
