%{
#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <algorithm>
#include "atributo.h"
#include "tabela_simbolo.h"
bool correto = true;
bool expressaoEstrutura = false;
bool escopoLoop = false;
bool comandoPrint = false;
bool comparacao = false;
std::string producaoAtual;
std::vector<std::string> expressoes;
std::string expressaoPronta = "";
std::string expressao = "";
std::string expAux = "";
std::string op = "";
std::string tipoExpressao = "";
std::string msgErro = "";
std::string nomeVariavel = "";
int escopoEspressao = 0;
int auxEscopoEspressao = -1;
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

FUNCDEF: DF IDF P1 PARAMLIST P2 CV1 {auxEscopoEspressao++; escopoEspressao = auxEscopoEspressao+1;} STATELIST CV2 {
    checarVariavelEscopo();
    escopoEspressao--;
  }
  ;

PARAMLIST: %empty {}
  | INT ID VI PARAMLIST {}
  | FLT ID VI PARAMLIST {}
  | STR ID VI PARAMLIST {}
  | INT ID {}
  | FLT ID {}
  | STR ID {}
  ;

STATEMENT: VARDECL PV {}
  | ATRIBSTAT PV {}
  | PRINTSTAT PV {}
  | READSTAT PV {}
  | RETURNSTAT PV {}
  | IFSTAT {}
  | FORSTAT {}
  | CV1 {auxEscopoEspressao++; escopoEspressao = auxEscopoEspressao+1;} STATELIST CV2 {
    checarVariavelEscopo();
    escopoEspressao--;
  }
  | BRK PV {
    if (!escopoLoop) {
      correto = false;
      if (msgErro == "") {
        msgErro = "O comando break na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" está fora de um escopo de laço de repetição.";
      }
    }
  }
  | PV {}
  ;

VARDECL: INT ID CL1 ICT CL2 {}
  | FLT ID CL1 ICT CL2 {}
  | STR ID CL1 ICT CL2 {}
  | INT ID {}
  | FLT ID {}
  | STR ID {}
  ;

ATRIBSTAT: LVALUE ATR EXPRESSION {}
  | LVALUE ATR ALLOCEXPRESSION {}
  | LVALUE ATR FUNCCALL {}
  ;

FUNCCALL: IDF P1 PARAMLISTCALL P2 {}
  ;

PARAMLISTCALL: %empty {}
  | ID VI PARAMLISTCALL {}
  | ID {}
  ;

PRINTSTAT: PR {comandoPrint = true;} EXPRESSION {}
  ;

READSTAT: RD LVALUE {}
  ;

RETURNSTAT: RET {}
  ;

IFSTAT: IF {expressaoEstrutura = true;} P1 EXPRESSION P2 {expressaoEstrutura = false;} STATEMENT {}
  | IFE {expressaoEstrutura = true;} P1 EXPRESSION P2 {expressaoEstrutura = false;} STATEMENT ELS STATEMENT {}
  ;

FORSTAT: FOR {expressaoEstrutura = true; escopoLoop = true;} P1 ATRIBSTAT PV EXPRESSION PV ATRIBSTAT P2 {expressaoEstrutura = false; expressao = ""; tipoExpressao = "";} STATEMENT {expressaoEstrutura = false; escopoLoop = false;}
  ;

STATELIST: STATEMENT STATELIST {}
  | STATEMENT {}
  ;

ALLOCEXPRESSION: NEW INT CL1 NUMEXPRESSION CL2 {}
  | NEW FLT CL1 NUMEXPRESSION CL2 {}
  | NEW STR CL1 NUMEXPRESSION CL2 {}
  ;

EXPRESSION: NUMEXPRESSION MER {comparacao = true;} NUMEXPRESSION {}
  | NUMEXPRESSION MAR {comparacao = true;} NUMEXPRESSION {}
  | NUMEXPRESSION MEI {comparacao = true;} NUMEXPRESSION {}
  | NUMEXPRESSION MAI {comparacao = true;} NUMEXPRESSION {}
  | NUMEXPRESSION CMP {comparacao = true;} NUMEXPRESSION {}
  | NUMEXPRESSION DIF {comparacao = true;} NUMEXPRESSION {}
  | NUMEXPRESSION {}
  ;

NUMEXPRESSION: TERM NTERM {
    if (!expressaoEstrutura) {
      if (op != "") {
        expressao = op+expressao;
        op = "";
      }
      expressoes.push_back(expressao);
      expressaoPronta = expressao;
      expressao = "";
      tipoExpressao = "";
    }
  }
  ;

NTERM: %empty {}
  | ADD TERM NTERM {
    if (!expressaoEstrutura) {
      op += "+";
    }
  }
  | SUB TERM NTERM {
    if (!expressaoEstrutura) {
      op += "-";
    }
  }
  ;

TERM: UNARYEXPR MUL UNARYEXPR {
    if (!expressaoEstrutura) {
      expressao += "*"+expAux;
    }
    expAux = "";
  }
  | UNARYEXPR DIV UNARYEXPR {
    if (!expressaoEstrutura) {
      expressao += "/"+expAux;
    }
    expAux = "";
  }
  | UNARYEXPR PRC UNARYEXPR {
    if (!expressaoEstrutura) {
      expressao += "%"+expAux;
    }
    expAux = "";
  }
  | UNARYEXPR {
    if (!expressaoEstrutura) {
      expressao += expAux;
    }
    expAux = "";
  }
  ;

UNARYEXPR: ADD AFACTOR {} // Produção para sinal +
  | SUB SFACTOR {} // Produção para sinal -
  | FACTOR {} // Produção sem sinal
  ;

AFACTOR: ICT {
    expAux += "+"+std::string(yytext);
    checaTipoExpressao("int");
  }
  | FCT {
    expAux += "+"+std::string(yytext);
    checaTipoExpressao("float");
  }
  | SCT {
    expAux += "+"+std::string(yytext);
    checaTipoExpressao("string");
  }
  | NL {}
  | LVALUE {}
  | P1 NUMEXPRESSION P2 {}
  ;

SFACTOR: ICT {
    expAux += "-"+std::string(yytext);
    checaTipoExpressao("int");
  }
  | FCT {
    expAux += "-"+std::string(yytext);
    checaTipoExpressao("float");
  }
  | SCT {
    expAux += "-"+std::string(yytext);
    checaTipoExpressao("string");
  }
  | NL {}
  | LVALUE {}
  | P1 NUMEXPRESSION P2 {}
  ;

FACTOR: ICT {
    expAux += yytext;
    checaTipoExpressao("int");
  }
  | FCT {
    expAux += yytext;
    checaTipoExpressao("float");
  }
  | SCT {
    expAux += yytext;
    checaTipoExpressao("string");
  }
  | NL {}
  | LVALUE {}
  | P1 NUMEXPRESSION P2 {}
  ;

LVALUE: ID {
    bool escopoDiferente = false;
    for (auto const& it: TabelaSimbolo::instancia()->getTabela()) {
      std::pair<std::string, std::pair<std::string, int>> par = it.first;
      std::pair<std::string, int> par2 = par.second;
      Atributo at = it.second;
      if ((par.first == yytext) && (par2.second == escopoEspressao)) {
        tipoExpressao = par2.first;
        escopoDiferente = false;
        break;
      } else {
        escopoDiferente = true;
      }
    }
    if (escopoDiferente) {
      for (auto const& it: TabelaSimbolo::instancia()->getTabela()) {
        std::pair<std::string, std::pair<std::string, int>> par = it.first;
        std::pair<std::string, int> par2 = par.second;
        Atributo at = it.second;
        if (par.first == yytext) {
          tipoExpressao = par2.first;
        }
      }
    }
  } NLVALUE {}
  ;

NLVALUE: %empty {}
  | CL1 NUMEXPRESSION CL2 NLVALUE {}
  ;

%%

void yyerror(const char *msg) {
  std::cout << "Erro de sintaxe. Linha: " << yylineno << ". Coluna: " << coluna() << "." << std::endl;
  /* std::cout << "Produção: " << producaoAtual << ". Token: " << tokenAtual() << ". Lexema: " << yytext << "." << std::endl; */
  correto = false;
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

std::string mensagemErro() {
  return msgErro;
}

void checarVariavelEscopo() {
  int i = 0;
  for (auto const& it1: TabelaSimbolo::instancia()->getTabela()) {
    std::pair<std::string, std::pair<std::string, int>> par1 = it1.first;
    std::pair<std::string, int> par2 = par1.second;
    Atributo at1 = it1.second;
    int j = 0;
    for (auto const& it2: TabelaSimbolo::instancia()->getTabela()) {
      if (i != j) {
        std::pair<std::string, std::pair<std::string, int>> par3 = it2.first;
        std::pair<std::string, int> par4 = par3.second;
        Atributo at2 = it2.second;
        /* std::cout << par1.first << " " << par2.first << " " << par1.second << " " << par2.second << " " << at1.escopo << " " << at2.escopo << std::endl; */
        /* && (par2.first != par4.first) */
        if ((par1.first == par3.first) && (par2.second == par4.second)) {
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
  if ((tipoExpressao != tipo) && (!comandoPrint) && (!comparacao)) {
    correto = false;
    if (msgErro == "") {
      msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
    }
  }
  if (comandoPrint) {
    comandoPrint = false;
  }
  if (comparacao) {
    comparacao = false;
  }
}
