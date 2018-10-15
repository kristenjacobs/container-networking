#!/bin/bash -e 
sudo ip netns exec con python3 -m http.server 8000 &
