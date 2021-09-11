#ifndef TABELA_SIMBOLO_H
#define TABELA_SIMBOLO_H

#include <iostream>
#include <string>
#include <map>
#include "atributo.h"
#include "posicao.h"

class TabelaSimbolo {
private:
  std::map<std::pair<std::string, std::pair<std::string, int>>, Atributo> tabela;
  static TabelaSimbolo *tInstancia;
  TabelaSimbolo() = default;

public:
  ~TabelaSimbolo();
  static TabelaSimbolo *instancia();
  bool inserir(std::string lexema, Posicao posicao, std::string tipo = "", int escopo = -1);
  void limpaTabela();
  std::map<std::pair<std::string, std::pair<std::string, int>>, Atributo> getTabela();
};

#endif
