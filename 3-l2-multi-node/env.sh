CON1="con1"
CON2="con2"

if [ $(hostname) == "container-networking-1" ]; then 
    NODE_IP="10.0.0.10"
    IP1="10.0.0.11"
    IP2="10.0.0.12"
    TO_NODE_IP="10.0.0.20"
    TO_IP1="10.0.0.21"
    TO_IP2="10.0.0.22"
else
    NODE_IP="10.0.0.20"
    IP1="10.0.0.21"
    IP2="10.0.0.22"
    TO_NODE_IP="10.0.0.10"
    TO_IP1="10.0.0.11"
    TO_IP2="10.0.0.12"
fi
