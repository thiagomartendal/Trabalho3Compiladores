#include "tabela_simbolo.h"

TabelaSimbolo *TabelaSimbolo::tInstancia = 0;

TabelaSimbolo *TabelaSimbolo::instancia() {
  if (tInstancia == 0) {
    tInstancia = new TabelaSimbolo();
  }
  return tInstancia;
}

TabelaSimbolo::~TabelaSimbolo() {
  delete tInstancia;
}

void TabelaSimbolo::inserir(std::string lexema, Posicao posicao, std::string tipo) {
  if (tipo == "") {
    std::map<std::pair<std::string, std::string>, Atributo>::iterator it;
    for (it = tabela.begin(); it != tabela.end(); it++) {
      std::pair<std::string, std::string> par = it->first;
      if (par.first == lexema) {
        tabela[std::pair<std::string, std::string>(par.first, par.second)].pos.insert(posicao);
        break;
      }
    }
  } else {
    tabela[std::make_pair(lexema, tipo)].pos.insert(posicao);
  }
}

void TabelaSimbolo::inserirEscopo(std::string lexema, int escopo, std::string tipo) {
  if (tipo == "") {
    std::map<std::pair<std::string, std::string>, Atributo>::iterator it;
    for (it = tabela.begin(); it != tabela.end(); it++) {
      std::pair<std::string, std::string> par = it->first;
      if (par.first == lexema) {
        tabela[std::pair<std::string, std::string>(par.first, par.second)].escopo = escopo;
        break;
      }
    }
  } else {
    tabela[std::pair<std::string, std::string>(lexema, tipo)].escopo = escopo;
  }
}

void TabelaSimbolo::limpaTabela() {
  tabela.clear();
}

std::map<std::pair<std::string, std::string>, Atributo> TabelaSimbolo::getTabela() {
  return tabela;
}
