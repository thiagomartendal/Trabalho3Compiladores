# Trabalho 2 - Análise Sintática

## Autores

Leandro Hideki Aihara

Thiago Martendal Salvador

Pablo Daniel Riveros Strapasson

## Sobre os programas escritos em LCC

Os programas de exemplos escritos na linguagem LCC a serem testados estão na pasta programas.

### programa-lcc-1.lcc

Se trata de um programa que calcula funções matemáticas para verificação de paridade, primalidade e cálculo de fibonacchi para números.

### programa-lcc-2.lcc

O programa 2 trás a implementação do método numérico de Birge Vieta, para calcular raizes para um polinômio.

### programa-lcc-3.lcc

No programa 3, é implementado um algoritmo que aplica algumas operações em conjuntos.

## Instalação

Para instalar o Flex, basta usar o comando do makefile:

make instalar-flex

## Compilação:

flex lexico.l

bison -d sintatico.y

g++ main.cpp entrada.cpp analise_lexica.cpp sintatico.tab.c lex.yy.c -lfl -o Main

## Execução:

### Realiza análise léxica

./Main -l LCC-2021-1-20210627/exemplo1.lcc

### Realiza análise sintática

./Main -s LCC-2021-1-20210627/exemplo1.lcc

## Compilação e Execução com makefile:

Esta seção trata o processo de compilação e execução automáticas com comandos do makefiel.

Compilação do projeto:

make compilar

Execução do programa 1 léxico:

programa1_lexico

Execução do programa 1 sintático:

make programa1_sintatico

Execução do programa 2 léxico:

make programa2_lexico

Execução do programa 2 sintático:

make programa2_sintatico

Execução do programa 3 léxico:

make programa3_lexico

Execução do programa 3 sintático:

make programa3_sintatico

## Importante:

O programa aceita arquivos com exensão .lcc e .ccc
