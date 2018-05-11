#!/bin/bash

sudo tshark -i $1 -T fields \
-e ip.src \
-e ip.dst \
-e frame.protocols \
-E header=y
