FROM ubuntu:18.04

RUN apt update && apt-get install -y \
    rsh-client \
    telnet \
    net-tools \
    iputils-ping \
    rsh-server \
    inetutils-inetd \
    && rm -rf /var/lib/apt/lists/*

#setting host inside /etc/hosts
CMD echo '172.28.1.2 x-terminal' >> /etc/hosts
# enabling fontoura to login without password on trusted-server
RUN echo '+ root' >> /etc/hosts.equiv && echo '172.28.1.2 fontoura' >> /root/.rhosts

#keep container running
ENTRYPOINT /etc/init.d/inetutils-inetd start && tail -f /dev/null