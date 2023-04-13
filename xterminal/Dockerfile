FROM ubuntu:18.04

RUN apt update && apt-get install -y \
    rsh-client \
    telnet \
    net-tools \
    iputils-ping \
    rsh-server \
    inetutils-inetd \
    && rm -rf /var/lib/apt/lists/*


# creating user fontoura
RUN useradd -m fontoura
# setting password for user fontoura
RUN echo 'fontoura:fontoura' | chpasswd
# setting trusted-server IP inside /etc/hosts
CMD echo '172.28.1.3' >> /etc/hosts
# enabling only fontoura to login without password as root from trusted-server
RUN echo '172.28.1.3 fontoura' >> /etc/hosts.equiv
RUN echo '172.28.1.3 root' >> /home/fontoura/.rhosts


#keep container running
ENTRYPOINT /etc/init.d/inetutils-inetd start && tail -f /dev/null
