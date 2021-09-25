#ifndef TABELA_SIMBOLO_H
#define TABELA_SIMBOLO_H

#include <iostream>
#include <string>
#include <map>
#include "atributo.h"
#include "posicao.h"

typedef struct LinhaTabela {
  std::string lexema;
  std::string tipo;
  Atributo atributo;
} LinhaTabela;

class TabelaSimbolo {
private:
  std::map<std::pair<std::string, std::pair<std::string, int>>, Atributo> tabela;
  // std::map<std::pair<std::string, std::string>, Atributo> tabela;
  static TabelaSimbolo *tInstancia;
  TabelaSimbolo() = default;

public:
  ~TabelaSimbolo();
  static TabelaSimbolo *instancia();
  bool inserir(std::string lexema, Posicao posicao, int escopo, int escopoFuncao, std::string tipo = "");
  void limpaTabela();
  std::map<std::pair<std::string, std::pair<std::string, int>>, Atributo> getTabela();
  // std::map<std::pair<std::string, std::string>, Atributo> getTabela();
  LinhaTabela retornarPorLinha(int linha);
  LinhaTabela retornarPorLinhaColuna(int linha, int coluna);
};

#endif
