#ifndef TABELA_SIMBOLO_H
#define TABELA_SIMBOLO_H

#include <iostream>
#include <string>
#include <map>
#include "atributo.h"
#include "posicao.h"

class TabelaSimbolo {
private:
  std::map<std::pair<std::string, std::string>, Atributo> tabela;
  static TabelaSimbolo *tInstancia;
  TabelaSimbolo() = default;

public:
  ~TabelaSimbolo();
  static TabelaSimbolo *instancia();
  void inserir(std::string lexema, Posicao posicao, std::string tipo = "");
  void inserirEscopo(std::string lexema, int escopo, std::string tipo = "");
  void limpaTabela();
  std::map<std::pair<std::string, std::string>, Atributo> getTabela();
};

#endif
