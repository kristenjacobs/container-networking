#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Incorect args. Usage: $0 <file basename to convert>"
    exit 1
fi
ffmpeg -i $1.mov $1.mp4
