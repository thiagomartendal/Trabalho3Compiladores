// Leandro Hideki Aihara
// Thiago Martendal Salvador
// Pablo Daniel Riveros Strapasson

#ifndef TOKEN_H
#define TOKEN_H

#include <string>
#include "posicao.h"
#include "sintatico.tab.h"

// O token é o elemento que configura a descrição de cada palavra no código

typedef struct Token {
  yytokentype id; // Identificador que determina o tipo do token, pode haver repetição de identificadores
  std::string lexema; // A palavra que compõe o token
  Posicao pos; // A linha e a coluna onde o lexema se encontra
  std::string descricao; // Descrição
} Token;

#endif
