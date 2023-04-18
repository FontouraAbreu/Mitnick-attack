FROM python:3.8

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


COPY ./scripts/requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY ./scripts /scripts
RUN chmod +x -R /scripts/

WORKDIR /scripts
#keep container running
CMD echo '172.28.1.2 x-terminal' >> /etc/hosts && tail -f /dev/null