#!/bin/bash -ex

sudo ip netns exec con python3 -m http.server
