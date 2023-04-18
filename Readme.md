# Mitnick Attack

## Contexto

Este é o trabalho para a disciplina de Segurança Computacional da Universidade Federal do Paraná. O objetivo é reproduzir o ataque de Kevin Mitnick e demonstrar que é possível obter acesso a uma rede interna sem a necessidade de um ataque de força bruta.

## [Entendendo o ataque de Mitnick](https://seedsecuritylabs.org/Labs_16.04/PDF/Mitnick_Attack.pdf)

***

## Entendendo nossa versão do ataque

### estrutura geral

3 containers docker:
    1. [attacker](attacker/Dockerfile)
    2. [trusted_server](trusted-server/Dockerfile)
    3. [x-terminal](xterminal/Dockerfile)

Os três containers estão na mesma rede e conseguem se enxergar. Entretanto, existe uma relação de confiança entre o trusted_server e o x-terminal. O x-terminal é um terminal que só pode ser acessaro a partir do trusted_server, sem a necessidade de senha.

O sistema de acesso remoto será feito usando rlogin.

### usuários

A máquina x-terminal possui um usuário chamado "fontoura" com senha "fontoura".

### attacker

A máquina attacker é uma máquina que está tentando acessar o x-terminal. Ela não tem acesso direto ao x-terminal mas tem acesso a rede interna.

### trusted_server

A máquina trusted_server é uma máquina que tem acesso direto ao x-terminal. Ela é a única máquina que pode acessar o x-terminal.

A largura de banda do trusted_server é limitada, para simular uma interface de rede lenta e sucetível a ataques de negação de serviço.
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

3. Realizando a negação de serviço

    Para realizar a negação de serviço, execute o seguinte comando no terminal do attacker:

    ```bash
    ./flood.sh
    ```

    O script flood.sh é um script que envia pacotes para o trusted_server. O objetivo é saturar a largura de banda do trusted_server, fazendo com que ele não consiga mais responder as requisições do x-terminal.

4. Capturando os pacotes

    Para capturar os pacotes, execute o seguinte comando no terminal do attacker:

    ```bash
    ./capture.sh
    ```

    O script capture.sh é um script que captura os pacotes que estão sendo enviados para o trusted_server.

5. Realizando a personificação

    Para realizar a personificação, execute o seguinte comando no terminal do attacker:

    ```bash
    python3

***

## Roadmap

- [X] colocar as maquinas na mesma rede
- [X] Criar um script para fazer o flood de pacotes
- [ ] x-terminal só pode ser acessado pelo trusted server
- [ ] fazer um mac spoofing e impersonar o trusted server
- [ ] fechar o x-terminal para ser acessado apenas pelo trusted server
