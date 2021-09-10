// Leandro Hideki Aihara
// Thiago Martendal Salvador
// Pablo Daniel Riveros Strapasson

#ifndef ATRIBUTO_H
#define ATRIBUTO_H

#include <set>
#include <string>
#include "posicao.h"

// O atributo é a estrutura de elementos alocada a cada identificador na tabela de símbolos

typedef struct Atributo {
  std::set<Posicao> pos; // Número das linhas onde ocorre o identificador
} Atributo;

#endif
