# Base stage
FROM ubuntu:18.04 as base

RUN apt update && apt-get install -y \
    rsh-client \
    rsh-server \
    net-tools \
    iputils-ping \
    tcpdump \
    && rm -rf /var/lib/apt/lists/*

# Stage 1: Trusted-server
FROM base as trusted-server
RUN apt-get update && apt-get install -y \
    inetutils-inetd \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Setting host inside /etc/hosts
CMD echo '172.28.1.2 x-terminal' >> /etc/hosts

# Keep container running
ENTRYPOINT /etc/init.d/inetutils-inetd start && tc qdisc add dev eth0 root tbf rate 800bit burst 1kbit latency 400ms && tail -f /dev/null


# Stage 2: xterminal
FROM base as xterminal

RUN apt-get update && apt-get install -y \
    inetutils-inetd \
    && rm -rf /var/lib/apt/lists/*

# Creating user fontoura
RUN useradd -m fontoura
# Setting password for user fontoura
RUN echo 'fontoura:fontoura' | chpasswd
# Setting trusted-server IP inside /etc/hosts
CMD echo '172.28.1.3 trusted-server' >> /etc/hosts
# Enabling only fontoura to login without password as root from trusted-server
RUN echo 'trusted-server fontoura' >> /etc/hosts.equiv
RUN echo 'trusted-server root' >> /home/fontoura/.rhosts

# Keep container running
ENTRYPOINT /etc/init.d/inetutils-inetd start && tail -f /dev/null


# Stage 3: Attacker
FROM base as attacker
# Set DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    hping3 \
    dsniff \
    && rm -rf /var/lib/apt/lists/*

# Keep container running
CMD echo '172.28.1.2 x-terminal' >> /etc/hosts && ifconfig eth0 promisc && tail -f /dev/null