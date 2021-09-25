# Trabalho 3 - Análise Semântica e Geração de Código Intermediário

## Autores

Leandro Hideki Aihara

Thiago Martendal Salvador

Pablo Daniel Riveros Strapasson

## Sobre o Trabalho 3

Este é o trabalho 3 da disciplina de construção de compiladores, tratamos sobre as fases de análise semântica e geração de código intermediário.

## Sobre os programas escritos em LCC

Os programas de exemplos escritos na linguagem LCC a serem testados estão na pasta programas.

### programa-lcc-1.lcc

Se trata de um programa que calcula funções matemáticas para verificação de paridade, primalidade e cálculo de fibonacchi para números.

### programa-lcc-2.lcc

O programa 2 trás a implementação do método numérico de Birge Vieta, para calcular raizes para um polinômio.

### programa-lcc-3.lcc

No programa 3, é implementado um algoritmo que aplica algumas operações em conjuntos.

### outros programas

Foram enviados também outros programas para se testar os recursos do trabalho 3.

## Instalação

Para instalar o Flex, basta usar o comando do makefile:

make instalar-flex

## Compilação:

flex lexico.l

bison -d sintatico.y

g++ main.cpp entrada.cpp analise_lexica.cpp tabela_simbolo.cpp lex.yy.c sintatico.tab.c -lfl -o Main

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

Execução do programa 4 léxico:

make programa4_lexico

Execução do programa 4 sintático:

make programa4_sintatico

Execução do programa 5 léxico:

make programa5_lexico

Execução do programa 5 sintático:

make programa5_sintatico

Execução do programa 6 léxico:

make programa6_lexico

Execução do programa 6 sintático:

make programa6_sintatico

Execução do programa 7 léxico:

make programa7_lexico

Execução do programa 7 sintático:

make programa7_sintatico

Execução do programa 8 léxico:

make programa8_lexico

Execução do programa 8 sintático:

make programa8_sintatico

Execução do programa 9 léxico:

make programa9_lexico

Execução do programa 9 sintático:

make programa9_sintatico

## Importante:

O programa aceita arquivos com exensão .lcc e .ccc
