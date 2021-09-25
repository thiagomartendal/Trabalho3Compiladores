// Leandro Hideki Aihara
// Thiago Martendal Salvador
// Pablo Daniel Riveros Strapasson

#ifndef ATRIBUTO_H
#define ATRIBUTO_H

#include <vector>
#include <set>
#include <string>
#include "posicao.h"

// O atributo é a estrutura de elementos alocada a cada identificador na tabela de símbolos

typedef struct Atributo {
  std::vector<Posicao> pos; // Número das linhas onde ocorre o identificador
  std::set<int> escopos; // Escopos onde a variável foi encontrada
  int escopoDeclaracao{-1}; // Escopo onde a variável foi declarada
  int escopoFuncao;
} Atributo;

#endif
