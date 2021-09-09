// Leandro Hideki Aihara
// Thiago Martendal Salvador
// Pablo Daniel Riveros Strapasson

#include "analise_lexica.h"

void AnaliseLexica::tokenizar(int ntoken, std::string lexema, int linha, int coluna) {
  yytokentype id; // Recebe o identificador do token
  std::string descricao; // Uma descrição do lexema
  // Abaixo segue a verificação dos tokens e as devidas atribuições
  if (ntoken == ERR) {
    id = ERR;
    descricao = "Erro léxico";
  } else {
    switch (ntoken) {
      case ID:
        id = ID;
        descricao = "Identificador";
      break;
      case IDF:
        id = IDF;
        descricao = "Identificador de função";
      break;
      case ICT:
        id = ICT;
        descricao = "Constante inteira";
      break;
      case FCT:
        id = FCT;
        descricao = "Constante real";
      break;
      case SCT:
        id = SCT;
        descricao = "Constante string";
      break;
      case ADD:
        id = ADD;
        descricao = "Adição";
      break;
      case SUB:
        id = SUB;
        descricao = "Subtração";
      break;
      case MUL:
        id = MUL;
        descricao = "Multiplicação";
      break;
      case DIV:
        id = DIV;
        descricao = "Divisão";
      break;
      case PRC:
        id = PRC;
        descricao = "Porcentagem";
      break;
      case ATR:
        id = ATR;
        descricao = "Atribuição";
      break;
      case MAR:
        id = MAR;
        descricao = "Maior";
      break;
      case MER:
        id = MER;
        descricao = "Menor";
      break;
      case CMP:
        id = CMP;
        descricao = "Comparação";
      break;
      case MAI:
        id = MAI;
        descricao = "Maior igual";
      break;
      case MEI:
        id = MEI;
        descricao = "Menor igual";
      break;
      case DIF:
        id = DIF;
        descricao = "Diferença";
      break;
      case P1:
        id = P1;
        descricao = "Parenteses de abertura";
      break;
      case P2:
        id = P2;
        descricao = "Parenteses de fechamento";
      break;
      case CV1:
        id = CV1;
        descricao = "Chave de abertura";
      break;
      case CV2:
        id = CV2;
        descricao = "Chave de fechamento";
      break;
      case CL1:
        id = CL1;
        descricao = "Colchete de abertura";
      break;
      case CL2:
        id = CL2;
        descricao = "Colchete de fechamento";
      break;
      case VI:
        id = VI;
        descricao = "Vírgula";
      break;
      case PV:
        id = PV;
        descricao = "Ponto e vírgula";
      break;
      case NEW:
        id = NEW;
        descricao = "Novo";
      break;
      case DF:
        id = DF;
        descricao = "Define função";
      break;
      case RD:
        id = RD;
        descricao = "Ler";
      break;
      case PR:
        id = PR;
        descricao = "Imprimir";
      break;
      case NL:
        id = NL;
        descricao = "Nulo";
      break;
      case INT:
        id = INT;
        descricao = "Tipo inteiro";
      break;
      case FLT:
        id = FLT;
        descricao = "Tipo float";
      break;
      case STR:
        id = STR;
        descricao = "Tipo string";
      break;
      case IF:
        id = IF;
        descricao = "Estrutura if";
      break;
      case ELS:
        id = ELS;
        descricao = "Estrutura else";
      break;
      case FOR:
        id = FOR;
        descricao = "Estrutura for";
      break;
      case BRK:
        id = BRK;
        descricao = "Quebra sequência";
      break;
      case RET:
        id = RET;
        descricao = "Retorno";
      break;
    }
  }
  Posicao p = {linha, coluna};
  if ((id == ID) || (id == IDF)) {
    // tabelaSimbolos[lexema].pos.insert(p); // Insere linha no conjunto de linhas de um lexema
    // TabelaSimbolo::instancia()->inserir(lexema, p);
  }
  Token token = {id, lexema, p, descricao}; // Monta o token
  tokens.push_back(token); // Adiciona o token a tabela de símbolos
}

void AnaliseLexica::limpaTokens() {
  tokens.clear(); // Limpa a lista de tokens
}

std::vector<Token> AnaliseLexica::getTokens() {
  return tokens; // Retorna a lista de tokens
}
