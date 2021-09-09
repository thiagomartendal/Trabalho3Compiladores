// Leandro Hideki Aihara
// Thiago Martendal Salvador
// Pablo Daniel Riveros Strapasson

#include <iostream>
#include <string>
#include "entrada.h"

int main(int argc, char *argv[]) { // O nome de um arquivo de entrada pode ser passado por argumento
  Entrada entrada;
  if (argc == 2) {
    entrada.lerEntrada(argv[1]);
  } else if (argc == 3) { // Se houver um arquivo de entrada, este é lido
    if ((std::string(argv[1]) == "-l") || (std::string(argv[1]) == "-s")) {
      entrada.lerArquivo(argv[2], argv[1]);
    } else if ((std::string(argv[2]) == "-l") || (std::string(argv[2]) == "-s")) {
      entrada.lerArquivo(argv[1], argv[2]);
    }
  } else { // Se não houver flags de opção, é exibida a mensagem
    std::cout << "Use a flag -l para indicar a análise léxica ou -s para indicar a análise sintática." << std::endl;
  }
  return 0;
}
