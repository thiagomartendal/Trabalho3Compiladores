// Leandro Hideki Aihara
// Thiago Martendal Salvador
// Pablo Daniel Riveros Strapasson

#ifndef POSICAO_H
#define POSICAO_H

// A posição é uma estrutura que armazena a linha e a coluna onde ocorre a palavra

typedef struct Posicao {
  int linha; // Linha atual
  int coluna; // Coluna atual
} Posicao;

// Método especial de análise para distinção de structs iguais em conjuntos
inline bool operator<(const Posicao &p1, const Posicao &p2) {
  if ((p1.linha <= p2.linha) && (p1.coluna < p2.coluna)) {
    return true;
  }
  return false;
}

#endif
