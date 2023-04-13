# Mitnick Attack

## Contexto

Este é o trabalho para a disciplina de Segurança Computacional da Universidade Federal do Paraná. O objetivo é reproduzir o ataque de Kevin Mitnick e demonstrar que é possível obter acesso a uma rede interna sem a necessidade de um ataque de força bruta.

## [Entendendo o ataque de Mitnick](https://seedsecuritylabs.org/Labs_16.04/PDF/Mitnick_Attack.pdf)

***

## Entendendo nossa versão do ataque

Dadas as dificuldade atual de reproduzir um TCP hijacking como no ataque real, optamos por fazer um flood

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

***

## Roadmap

- [X] colocar as maquinas na mesma rede
- [ ] Criar um script para fazer o flood de pacotes
- [ ] fazer um mac spoofing e impersonar o trusted server
- [ ] fechar o x-terminal para ser acessado apenas pelo trusted server
