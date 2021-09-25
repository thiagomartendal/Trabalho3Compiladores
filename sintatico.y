%{
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include "tabela_simbolo.h"

bool correto = true;
bool erroSintaxe = false;
std::string tipoVarAtrib = "";

bool expressaoEstrutura = false;
bool operadorExpressao = false;
bool escopoLoop = false;
bool comandoPrint = false;
bool comandoRead = false;
bool comparacao = false;
std::string producaoAtual;
std::vector<std::string> expressoes;
std::string expressao = "";
std::string expAux = "";
std::string op = "";
std::string msgErro = "";
int escopoEspressao = 0;
int auxEscopoEspressao = -1;
int escopoFuncaoAtual = -1;

std::vector<std::string> linhasCodigoGerado;
std::string preCodigo = "";
std::string expAtrib = "";
std::string varAtrib = "";
std::string desvio = "";
std::string labelLoop = "";
std::string labelFuncao = "";
std::string parametrosFuncao = "";
std::string ponteiroIndiceVetor = "";
bool condicao = false;
bool identificadorChave = false;
bool atribuicaoVetor = false;
bool ponteiroChave = false;
bool vetorAlocado = false;
int indiceLabel = 0;
int indiceAtribuicao = 0;
int labelDesvio = -1;
void avaliarCondicao(std::string operador);

void checarVariavelEscopo();

extern int yylex();
extern void yyerror(const char*);
extern int yylineno;
extern int yylval;
extern char* yytext;
extern "C" {
  bool programaCorreto(void);
  int coluna();
  const char* tokenAtual();
  std::vector<std::string> arvoreExpressao();
  std::vector<std::string> codigoIntermediario();
  std::string mensagemErro();
  std::string erroNaInicializacao();
  std::string erroMultiplaDeclaracao();
  void checaTipoExpressao(std::string tipo);
}
%}

%token ID
%token IDF
%token ICT
%token FCT
%token SCT
%token ADD
%token SUB
%token MUL
%token DIV
%token PRC
%token ATR
%token MAR
%token MER
%token CMP
%token MAI
%token MEI
%token DIF
%token P1
%token P2
%token CV1
%token CV2
%token CL1
%token CL2
%token VI
%token PV
%token NEW
%token DF
%token RD
%token PR
%token NL
%token INT
%token FLT
%token STR
%token IF
%token IFE
%token ELS
%token FOR
%token BRK
%token RET
%token ERR
%token END 0

%right P2 ELS

%%
input: %empty
  | input line
  ;

line: '\n'
  | exp '\n'
  ;

exp: PROGRAM
  ;

PROGRAM: STATEMENT {}
  | FUNCLIST {}
  ;

FUNCLIST: FUNCDEF FUNCLIST {}
  | FUNCDEF {}
  ;

FUNCDEF: DF {escopoFuncaoAtual++;} IDF {
    LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, coluna());
    if (linha.lexema != "") {
      labelFuncao += linha.lexema;
    }
  } P1 {labelFuncao += "(";} PARAMLIST {labelFuncao += ")";} P2 {
    if (labelFuncao != "") {
      linhasCodigoGerado.push_back(labelFuncao+":");
      labelFuncao = "";
    }
  } CV1 {auxEscopoEspressao++; escopoEspressao = auxEscopoEspressao+1;} STATELIST CV2 {
    checarVariavelEscopo();
    escopoEspressao--;
  }
  ;

PARAMLIST: %empty {}
  | INT ID {
    int col = coluna();
    LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    while (linha.lexema == "") {
      col -= 1;
      linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    }
    labelFuncao += linha.lexema+", ";
  } VI PARAMLIST {}
  | FLT ID {
    int col = coluna();
    LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    while (linha.lexema == "") {
      col -= 1;
      linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    }
    labelFuncao += linha.lexema+", ";
  } VI PARAMLIST {}
  | STR ID {
    int col = coluna();
    LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    while (linha.lexema == "") {
      col -= 1;
      linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    }
    labelFuncao += linha.lexema+", ";
  } VI PARAMLIST {}
  | INT ID {
    int col = coluna();
    LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    while (linha.lexema == "") {
      col -= 1;
      linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    }
    labelFuncao += linha.lexema;
  }
  | FLT ID {
    int col = coluna();
    LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    while (linha.lexema == "") {
      col -= 1;
      linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    }
    labelFuncao += linha.lexema;
  }
  | STR ID {
    int col = coluna();
    LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    while (linha.lexema == "") {
      col -= 1;
      linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    }
    labelFuncao += linha.lexema;
  }
  ;

STATEMENT: VARDECL PV {}
  | {
      LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, coluna());
      if (linha.lexema != "") {
        tipoVarAtrib = linha.tipo;
      }
    } ATRIBSTAT {tipoVarAtrib = "";} PV {}
  | PRINTSTAT PV {}
  | READSTAT PV {}
  | RETURNSTAT PV {}
  | IFSTAT {}
  | FORSTAT {}
  | CV1 {auxEscopoEspressao++; escopoEspressao = auxEscopoEspressao+1;} STATELIST CV2 {
    checarVariavelEscopo();
    escopoEspressao--;
  }
  | BRK {linhasCodigoGerado.push_back("break");} PV {
    if (!escopoLoop) {
      correto = false;
      if (msgErro == "") {
        msgErro = "O comando break na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" está fora de um escopo de laço de repetição.";
      }
    }
  }
  | PV {}
  ;

VARDECL: INT ID BRACKET {}
  | FLT ID BRACKET {}
  | STR ID BRACKET {}
  | INT ID {}
  | FLT ID {}
  | STR ID {}
  ;

BRACKET: CL1 ICT CL2 {}
  | CL1 ICT CL2 BRACKET {}
  ;

ATRIBSTAT: LVALUE ATR {
  if (!condicao) {
    preCodigo += varAtrib;
  }
  varAtrib = "";
  expAux = "";
  expressao = "";
  expAtrib = "";
  } EXPRESSION {
    if (condicao) {
      LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinha(yylineno);
      preCodigo += linha.lexema+" = "+expAtrib;
      expAtrib = "";
    } else {
      if (atribuicaoVetor) {
        std::string atribuicao = "t"+std::to_string(indiceAtribuicao)+" = "+expAtrib;
        linhasCodigoGerado.push_back(atribuicao);
        expAtrib = "";
        atribuicao = "*t"+std::to_string(indiceAtribuicao-1)+" = t"+std::to_string(indiceAtribuicao);
        linhasCodigoGerado.push_back(atribuicao);
        atribuicaoVetor = false;
        indiceAtribuicao++;
      } else {
        preCodigo += " = "+expAtrib;
        expAtrib = "";
        linhasCodigoGerado.push_back(preCodigo);
        preCodigo = "";
      }
    }
    varAtrib = "";
  }
  | LVALUE ATR {
    LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinha(yylineno);
    preCodigo += linha.lexema+" = ";
  } ALLOCEXPRESSION {}
  | LVALUE ATR {
    if (!condicao) {
      preCodigo += varAtrib+" = ";
    }
    varAtrib = "";
    expAux = "";
    expressao = "";
    expAtrib = "";
  } FUNCCALL {}
  ;

FUNCCALL: {
    LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, coluna());
    if (linha.lexema != "") {
      preCodigo += linha.lexema;
    }
  } IDF P1 {preCodigo += "(";} PARAMLISTCALL P2 {preCodigo += ")";} {
    linhasCodigoGerado.push_back(preCodigo);
    preCodigo = "";
  }
  ;

PARAMLISTCALL: %empty {}
  | ID {
    int col = coluna();
    LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    while (linha.lexema == "") {
      col -= 1;
      linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    }
    preCodigo += linha.lexema+", ";
  } VI PARAMLISTCALL {}
  | ID {
    int col = coluna();
    LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    while (linha.lexema == "") {
      col -= 1;
      linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, col);
    }
    preCodigo += linha.lexema;
  }
  ;

PRINTSTAT: PR {comandoPrint = true;} EXPRESSION {
    linhasCodigoGerado.push_back("print "+expAtrib);
    expAtrib = "";
  }
  ;

READSTAT: RD {comandoRead = true;} LVALUE {
    linhasCodigoGerado.push_back("read "+varAtrib);
    varAtrib = "";
    comandoRead = false;
  }
  ;

RETURNSTAT: RET {linhasCodigoGerado.push_back("return");}
  ;

IFSTAT: IF {expressaoEstrutura = true;} P1 {condicao = true;} EXPRESSION {
    linhasCodigoGerado.push_back(preCodigo);
    preCodigo = "";
    expAtrib = "";
  } P2 {
    expressaoEstrutura = false;
    condicao = false;
  } STATEMENT {
    linhasCodigoGerado.push_back(desvio+": ");
    desvio = "";
  }
  | IFE {expressaoEstrutura = true;} P1 {condicao = true;} EXPRESSION {
      linhasCodigoGerado.push_back(preCodigo);
      preCodigo = "";
      expAtrib = "";
    } P2 {expressaoEstrutura = false; condicao = false;} STATEMENT ELS {
      linhasCodigoGerado.push_back(desvio+": ");
      desvio = "";
    } STATEMENT {}
  ;

FORSTAT: FOR {expressaoEstrutura = true; escopoLoop = true;} P1 {condicao = true;} ATRIBSTAT {linhasCodigoGerado.push_back(preCodigo); preCodigo = "";} PV {
  labelLoop = "L"+std::to_string(indiceLabel);
  preCodigo += labelLoop+": ";
  indiceLabel++;
  labelDesvio = indiceLabel;
  } EXPRESSION {linhasCodigoGerado.push_back(preCodigo); preCodigo = ""; expAtrib = "";} PV ATRIBSTAT {linhasCodigoGerado.push_back(preCodigo); preCodigo = ""; condicao = false;} P2 {expressaoEstrutura = false; expressao = ""; condicao = false;} STATEMENT {
    linhasCodigoGerado.push_back("goto "+labelLoop);
    labelLoop = "";
    expressaoEstrutura = false;
    escopoLoop = false;
    if (desvio != "") {
      linhasCodigoGerado.push_back(desvio+":");
      desvio = "";
    }
  }
  ;

STATELIST: STATEMENT STATELIST {}
  | STATEMENT {}
  ;

ALLOCEXPRESSION: NEW INT {preCodigo += "new int"; vetorAlocado = true; expAtrib = "";} ALLOC {}
  | NEW FLT {preCodigo += "new float"; vetorAlocado = true; expAtrib = "";} ALLOC {}
  | NEW STR {preCodigo += "new string"; vetorAlocado = true; expAtrib = "";} ALLOC {}
  ;

ALLOC: CL1 NUMEXPRESSION CL2 {preCodigo += "["+expAtrib+"]"; linhasCodigoGerado.push_back(preCodigo); vetorAlocado = false; preCodigo = ""; expAtrib = "";}
  | CL1 NUMEXPRESSION CL2 {preCodigo += "["+expAtrib+"]"; expAtrib = "";} ALLOC {}

EXPRESSION: NUMEXPRESSION {comparacao = true; expAtrib = "";} MER NUMEXPRESSION {
    if (condicao) {
      avaliarCondicao("<");
    }
  }
  | NUMEXPRESSION MAR {comparacao = true; expAtrib = "";} NUMEXPRESSION {
    if (condicao) {
      avaliarCondicao(">");
    }
  }
  | NUMEXPRESSION MEI {comparacao = true; expAtrib = "";} NUMEXPRESSION {
    if (condicao) {
      avaliarCondicao("<=");
    }
  }
  | NUMEXPRESSION MAI {comparacao = true; expAtrib = "";} NUMEXPRESSION {
    if (condicao) {
      avaliarCondicao(">=");
    }
  }
  | NUMEXPRESSION CMP {comparacao = true; expAtrib = "";} NUMEXPRESSION {
    if (condicao) {
      avaliarCondicao("==");
    }
  }
  | NUMEXPRESSION DIF {comparacao = true; expAtrib = "";} NUMEXPRESSION {
    if (condicao) {
      avaliarCondicao("!=");
    }
  }
  | NUMEXPRESSION {}
  ;

NUMEXPRESSION: TERM NTERM {
    if (!expressaoEstrutura && operadorExpressao) {
      if (op != "") {
        expressao = op+expressao;
        op = "";
      }
      expressoes.push_back(expressao);
      expressao = "";
      operadorExpressao = false;
    }
  }
  ;

NTERM: %empty {}
  | ADD {expAtrib += "+";} TERM NTERM {
    if (!expressaoEstrutura) {
      op += "+";
      expressao += expAux;
      operadorExpressao = true;
    }
    expAux = "";
  }
  | SUB {expAtrib += "-";} TERM NTERM {
    if (!expressaoEstrutura) {
      op += "-";
      expressao += expAux;
      operadorExpressao = true;
    }
    expAux = "";
  }
  ;

TERM: UNARYEXPR MUL {expAtrib += "*";} UNARYEXPR {
    if (!expressaoEstrutura) {
      expressao += "*"+expAux;
      operadorExpressao = true;
    }
    expAux = "";
  }
  | UNARYEXPR DIV {expAtrib += "/";} UNARYEXPR {
    if (!expressaoEstrutura) {
      expressao += "/"+expAux;
      operadorExpressao = true;
    }
    expAux = "";
  }
  | UNARYEXPR PRC {expAtrib += "%";} UNARYEXPR {
    if (!expressaoEstrutura) {
      expressao += "%"+expAux;
      operadorExpressao = true;
    }
    expAux = "";
  }
  | UNARYEXPR {
      if (!expressaoEstrutura) {
        expressao += expAux;
      }
      if (identificadorChave && (expAux != "")) {
        if (ponteiroIndiceVetor != "") {
          ponteiroIndiceVetor += " + ";
        }
        ponteiroIndiceVetor += expAux;
      }
      expAux = "";
  }
  ;

UNARYEXPR: ADD AFACTOR {} // Produção para sinal +
  | SUB SFACTOR {} // Produção para sinal -
  | FACTOR {} // Produção sem sinal
  ;

AFACTOR: ICT {
    expAtrib += "+"+std::string(yytext);
    expAux += "+"+std::string(yytext);
    if (!vetorAlocado) {
      checaTipoExpressao("int");
    }
  }
  | FCT {
    expAtrib += "+"+std::string(yytext);
    expAux += "+"+std::string(yytext);
    if (!vetorAlocado) {
      checaTipoExpressao("float");
    }
  }
  | SCT {
    expAtrib += "+"+std::string(yytext);
    expAux += "+"+std::string(yytext);
    if (!vetorAlocado) {
      checaTipoExpressao("string");
    }
  }
  | NL {expAtrib += "null"; expAux += "null";}
  | LVALUE {}
  | P1 NUMEXPRESSION P2 {}
  ;

SFACTOR: ICT {
    expAtrib += "-"+std::string(yytext);
    expAux += "-"+std::string(yytext);
    if (!vetorAlocado) {
      checaTipoExpressao("int");
    }
  }
  | FCT {
    expAtrib += "-"+std::string(yytext);
    expAux += "-"+std::string(yytext);
    if (!vetorAlocado) {
      checaTipoExpressao("float");
    }
  }
  | SCT {
    expAtrib += "-"+std::string(yytext);
    expAux += "-"+std::string(yytext);
    if (!vetorAlocado) {
      checaTipoExpressao("string");
    }
  }
  | NL {expAtrib += "null"; expAux += "null";}
  | LVALUE {}
  | P1 NUMEXPRESSION P2 {}
  ;

FACTOR: ICT {
    expAtrib += yytext;
    expAux += yytext;
    if (!vetorAlocado) {
      checaTipoExpressao("int");
    }
  }
  | FCT {
    expAtrib += yytext;
    expAux += yytext;
    if (!vetorAlocado) {
      checaTipoExpressao("float");
    }
  }
  | SCT {
    expAtrib += yytext;
    expAux += yytext;
    if (!vetorAlocado) {
      checaTipoExpressao("string");
    }
  }
  | NL {expAtrib += "null"; expAux += "null";}
  | LVALUE {}
  | P1 NUMEXPRESSION P2 {}
  ;

LVALUE: {
  LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, coluna());
  if (linha.lexema != "") {
    if (!identificadorChave && !vetorAlocado) {
      expAtrib += linha.lexema;
      expAux += linha.lexema;
      varAtrib = linha.lexema;
      checaTipoExpressao(linha.tipo);
    } else {
      std::string atribuicao = "t"+std::to_string(indiceAtribuicao)+" = t"+std::to_string(indiceAtribuicao-1)+" + "+linha.lexema;
      linhasCodigoGerado.push_back(atribuicao);
      indiceAtribuicao++;
    }
  }
  } ID {
    if (comandoRead) {
      LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinhaColuna(yylineno, coluna());
      if (linha.lexema != "") {
        if (!identificadorChave) {
          varAtrib = linha.lexema;
        }
      }
    }
  } NLVALUE {}
  ;

NLVALUE: %empty {
  identificadorChave = false;
  if (ponteiroChave) {
    ponteiroChave = false;
    std::string atribuicao = "t"+std::to_string(indiceAtribuicao)+" = t"+std::to_string(indiceAtribuicao-1)+" + "+ponteiroIndiceVetor;
    linhasCodigoGerado.push_back(atribuicao);
    indiceAtribuicao++;
    ponteiroIndiceVetor = "";
  }
}
  | {
    if (!ponteiroChave && !vetorAlocado) {
      std::string atribuicao = "t"+std::to_string(indiceAtribuicao)+" = &"+expAtrib;
      linhasCodigoGerado.push_back(atribuicao);
      atribuicaoVetor = true;
      indiceAtribuicao++;
      expAtrib = "";
      identificadorChave = true;
      varAtrib = "";
      expAux = "";
      ponteiroChave = true;
    }
  } CL1 NUMEXPRESSION CL2 NLVALUE {}
  ;

%%

void yyerror(const char *msg) {
  std::cout << "Erro de sintaxe. Linha: " << yylineno << ". Coluna: " << coluna() << "." << std::endl;
  correto = false;
  erroSintaxe = true;
  msgErro = "";
}

bool programaCorreto() {
  if (erroNaInicializacao() != "") {
    correto = false;
    msgErro = erroNaInicializacao();
  } else if (erroMultiplaDeclaracao() != "") {
    correto = false;
    msgErro = erroMultiplaDeclaracao();
  }
  return correto;
}

std::vector<std::string> arvoreExpressao() {
  return expressoes;
}

std::vector<std::string> codigoIntermediario() {
  return linhasCodigoGerado;
}

std::string mensagemErro() {
  if (erroSintaxe) {
    return "";
  }
  return msgErro;
}

void checarVariavelEscopo() {
  int i = 0;
  for (auto const& it1: TabelaSimbolo::instancia()->getTabela()) {
    std::pair<std::string, std::pair<std::string, int>> par1 = it1.first;
    std::pair<std::string, int> par2 = par1.second;
    Atributo at1 = it1.second;
    for (int escopo: at1.escopos) {
      if (escopo < at1.escopoDeclaracao) {
        msgErro = "A variável "+par1.first+" foi utilizada fora do escopo em que foi declarada.";
        correto = false;
        break;
      }
    }
    if (!correto) {
      break;
    }
    int j = 0;
    for (auto const& it2: TabelaSimbolo::instancia()->getTabela()) {
      if (i != j) {
        std::pair<std::string, std::pair<std::string, int>> par2 = it2.first;
        Atributo at2 = it2.second;
        if ((par1.first == par2.first) && (at1.escopoDeclaracao == at2.escopoDeclaracao)) {
          correto = false;
          msgErro = "A variável "+par1.first+" foi declarada duas vezes no mesmo escopo.";
          break;
        }
      }
      j++;
    }
    i++;
  }
}

void checaTipoExpressao(std::string tipo) {
  LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinha(yylineno);
  if (linha.lexema != "") {
    if ((!comandoPrint) && (!comparacao) && (!identificadorChave)) {
      if ((linha.tipo != tipo)) {
        correto = false;
        if (msgErro == "") {
          msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
        }
      } else if ((tipoVarAtrib != "") && (tipoVarAtrib != tipo)) {
        correto = false;
        if (msgErro == "") {
          msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
        }
      }
    }
  }
  if (comandoPrint) {
    comandoPrint = false;
  }
  if (comparacao) {
    comparacao = false;
  }
}

void avaliarCondicao(std::string operador) {
  LinhaTabela linha = TabelaSimbolo::instancia()->retornarPorLinha(yylineno);
  desvio = "L"+std::to_string(indiceLabel);
  preCodigo += "if "+linha.lexema;
  if (operador == "<") {
    preCodigo += " >= ";
  } else if (operador == ">") {
    preCodigo += " <= ";
  } else if (operador == "<=") {
    preCodigo += " > ";
  } else if (operador == ">=") {
    preCodigo += " < ";
  } else if (operador == "==") {
    preCodigo += " != ";
  } else if (operador == "!=") {
    preCodigo += " == ";
  }
  preCodigo += expAtrib+" goto "+desvio;
  indiceLabel++;
}
