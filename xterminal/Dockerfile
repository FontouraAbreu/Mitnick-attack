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
# setting host inside /etc/hosts
RUN echo '172.28.1.3 fontoura' >> /home/fontoura/.rhosts
# setting password for user fontoura
RUN echo 'fontoura:fontoura' | chpasswd



#keep container running
CMD echo '172.28.1.3 trusted' >> /etc/hosts
ENTRYPOINT /etc/init.d/inetutils-inetd start && tail -f /dev/null
