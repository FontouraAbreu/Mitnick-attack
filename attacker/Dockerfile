FROM ubuntu:18.04

RUN apt update && apt-get install -y \
    rsh-client \
    telnet \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

#keep container running
CMD tail -f /dev/null