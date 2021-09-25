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

bool TabelaSimbolo::inserir(std::string lexema, Posicao posicao, int escopo, int escopoFuncao, std::string tipo) {
  if (tipo == "") {
    std::map<std::pair<std::string, std::pair<std::string, int>>, Atributo>::iterator it;
    // std::map<std::pair<std::string, std::string>, Atributo>::iterator it;
    for (it = tabela.begin(); it != tabela.end(); it++) {
      std::pair<std::string, std::pair<std::string, int>> par = it->first;
      std::pair<std::string, int> par2 = par.second;
      // std::pair<std::string, std::string> par = it->first;
      if ((par.first == lexema) && (par2.second == escopoFuncao)) {
        tabela[std::pair<std::string, std::pair<std::string, int>>(par.first, std::make_pair(par2.first, escopoFuncao))].pos.push_back(posicao);
        tabela[std::pair<std::string, std::pair<std::string, int>>(par.first, std::make_pair(par2.first, escopoFuncao))].escopos.insert(escopo);
        // tabela[std::pair<std::string, std::string>(par.first, par.second)].pos.push_back(posicao);
        // tabela[std::pair<std::string, std::string>(par.first, par.second)].escopos.insert(escopo);
        return true;
      } else if ((par.first == lexema) && (par2.first == "função") && (par2.second != escopoFuncao)) {
        tabela[std::pair<std::string, std::pair<std::string, int>>(par.first, std::make_pair(par2.first, par2.second))].pos.push_back(posicao);
        tabela[std::pair<std::string, std::pair<std::string, int>>(par.first, std::make_pair(par2.first, par2.second))].escopos.insert(escopo);
        return true;
      }
    }
    return false;
  } else {
    tabela[std::make_pair(lexema, std::make_pair(tipo, escopoFuncao))].pos.push_back(posicao);
    tabela[std::make_pair(lexema, std::make_pair(tipo, escopoFuncao))].escopos.insert(escopo);
    if (tabela[std::make_pair(lexema, std::make_pair(tipo, escopoFuncao))].escopoDeclaracao == -1) {
      tabela[std::make_pair(lexema, std::make_pair(tipo, escopoFuncao))].escopoDeclaracao = escopo;
    }
    tabela[std::pair<std::string, std::pair<std::string, int>>(lexema, std::make_pair(tipo, escopoFuncao))].escopoFuncao = escopoFuncao;
    // tabela[std::make_pair(lexema, tipo)].pos.push_back(posicao);
    // tabela[std::make_pair(lexema, tipo)].escopos.insert(escopo);
    // if (tabela[std::make_pair(lexema, tipo)].escopoDeclaracao == -1) {
    //   tabela[std::make_pair(lexema, tipo)].escopoDeclaracao = escopo;
    // }
    // tabela[std::pair<std::string, std::string>(lexema, tipo)].escopoFuncao = escopoFuncao;
  }
  return true;
}

void TabelaSimbolo::limpaTabela() {
  tabela.clear();
}

std::map<std::pair<std::string, std::pair<std::string, int>>, Atributo> TabelaSimbolo::getTabela() {
  return tabela;
}

// std::map<std::pair<std::string, std::string>, Atributo> TabelaSimbolo::getTabela() {
//   return tabela;
// }

LinhaTabela TabelaSimbolo::retornarPorLinha(int linha)  {
  for (auto const& it: tabela) {
    std::pair<std::string, std::pair<std::string, int>> par = it.first;
    std::pair<std::string, int> par2 = par.second;
    // std::pair<std::string, std::string> par = it.first;
    Atributo at = it.second;
    for (Posicao p: at.pos) {
      if (p.linha == linha) {
        return {par.first, par2.first, at};
      }
    }
  }
  return {};
}

LinhaTabela TabelaSimbolo::retornarPorLinhaColuna(int linha, int coluna) {
  for (auto const& it: tabela) {
    std::pair<std::string, std::pair<std::string, int>> par = it.first;
    std::pair<std::string, int> par2 = par.second;
    // std::pair<std::string, std::string> par = it.first;
    Atributo at = it.second;
    for (Posicao p: at.pos) {
      if ((p.linha == linha) && (p.coluna == coluna)) {
        return {par.first, par2.first, at};
      }
    }
  }
  return {};
}
