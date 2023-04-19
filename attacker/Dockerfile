FROM ubuntu:18.04

RUN apt update && apt-get install -y \
    rsh-client \
    telnet \
    net-tools \
    iputils-ping \
    hping3 \
    dsniff \
    tcpdump \
    nano \
    && rm -rf /var/lib/apt/lists/*


#keep container running
CMD echo '172.28.1.2 x-terminal' >> /etc/hosts && ifconfig eth0 promisc && tail -f /dev/null