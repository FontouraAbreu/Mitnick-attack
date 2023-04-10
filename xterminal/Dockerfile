FROM ubuntu:18.04

RUN apt update && apt-get install -y \
    rsh-client \
    telnet \
    net-tools \
    iputils-ping \
    rsh-server \
    && rm -rf /var/lib/apt/lists/*


RUN /etc/init.d/openbsd-inet start

RUN echo '172.28.1.3 fontoura' >> /root/.rhosts
RUN useradd -m fontoura
RUN echo 'fontoura:fontoura' | chpasswd



#keep container running
CMD echo '172.28.1.3 trusted' >> /etc/hosts
ENTRYPOINT tail -f /dev/null