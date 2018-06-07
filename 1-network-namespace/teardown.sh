#!/bin/bash

. env.sh

echo "Deleting the namespaces"
ip netns list | grep $CON
if [ $? -eq 0 ]; then
    sudo ip netns delete $CON
fi
