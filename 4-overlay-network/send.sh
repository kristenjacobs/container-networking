#!/bin/bash

. env.sh

sudo ip netns exec con1 ping $TO_IP1
