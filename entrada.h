// Leandro Hideki Aihara
// Thiago Martendal Salvador
// Pablo Daniel Riveros Strapasson

#ifndef ENTRADA_H
#define ENTRADA_H

#include <iostream>
#include <string>
#include <vector>
#include "analise_lexica.h"
#include "tabela_simbolo.h"
#include "sintatico.tab.h"

extern "C" int coluna();
extern "C" bool programaCorreto();
extern "C" std::vector<std::string> arvoreExpressao();
extern "C" std::string mensagemErro();
extern int yylex();
extern int yyparse();
extern int yylineno;
extern char* yytext;
extern FILE *yyin;


class Entrada {
private:
  std::vector<std::string> entrada;
  AnaliseLexica al; // Classe de análise léxica
  bool houveErro(); // Checa se houve um erro léxico
  void analiseLexicaArquivo(); // Lê um arquivo para a analise lexica
  void analiseSintaticaArquivo(); // Lê um arquivo para a analise sintatica
  void analiseLexicaEntrada(); // Lê uma entrada para a analise lexica

public:
  Entrada() = default;
  bool lerArquivo(std::string nome, std::string flag); // Lê arquivo
  void lerEntrada(std::string flag); // Lê linha do console
  void exibirTokens(); // Exibe os tokens processados
  void exibirTabelaSimbolos(); // Exibe a tabela de símbolos
};

#endif
