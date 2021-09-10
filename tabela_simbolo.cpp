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

bool TabelaSimbolo::inserir(std::string lexema, Posicao posicao, std::string tipo, int escopo) {
  if (tipo == "") {
    std::map<std::pair<std::string, std::pair<std::string, int>>, Atributo>::iterator it;
    for (it = tabela.begin(); it != tabela.end(); it++) {
      std::pair<std::string, std::pair<std::string, int>> par = it->first;
      std::pair<std::string, int> par2 = par.second;
      if (par.first == lexema) {
        tabela[std::pair<std::string, std::pair<std::string, int>>(par.first, std::make_pair(par2.first, par2.second))].pos.insert(posicao);
        return true;
      }
    }
    return false;
  } else {
    tabela[std::make_pair(lexema, std::make_pair(tipo, escopo))].pos.insert(posicao);
  }
  return true;
}

// void TabelaSimbolo::inserirEscopo(std::string lexema, int escopo, std::string tipo) {
//   if (tipo == "") {
//     std::map<std::pair<std::string, std::string>, Atributo>::iterator it;
//     for (it = tabela.begin(); it != tabela.end(); it++) {
//       std::pair<std::string, std::string> par = it->first;
//       if (par.first == lexema) {
//         tabela[std::pair<std::string, std::string>(par.first, par.second)].escopo = escopo;
//         break;
//       }
//     }
//   } else {
//     tabela[std::pair<std::string, std::string>(lexema, tipo)].escopo = escopo;
//   }
// }

void TabelaSimbolo::limpaTabela() {
  tabela.clear();
}

std::map<std::pair<std::string, std::pair<std::string, int>>, Atributo> TabelaSimbolo::getTabela() {
  return tabela;
}
