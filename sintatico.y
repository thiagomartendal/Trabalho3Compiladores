%{
#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <algorithm>
#include "atributo.h"
#include "tabela_simbolo.h"
bool correto = true;
bool expressaoLoop = false;
bool escopoLoop = false;
std::string producaoAtual;
std::vector<std::string> expressoes;
std::string expressaoPronta = "";
std::string expressao = "";
std::string expAux = "";
std::string op = "";
std::string tipoExpressao = "";
std::string msgErro = "";
std::string nomeVariavel = "";
int escopoEspressao = -1;
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

FUNCDEF: DF IDF P1 PARAMLIST P2 CV1 {escopoEspressao++;} STATELIST CV2 {escopoEspressao--;}
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
  | CV1 {escopoEspressao++;} STATELIST CV2 {
    for (auto const& it1: TabelaSimbolo::instancia()->getTabela()) {
      std::pair<std::string, std::string> par1 = it1.first;
      Atributo at1 = it1.second;
      for (auto const& it2: TabelaSimbolo::instancia()->getTabela()) {
        std::pair<std::string, std::string> par2 = it2.first;
        Atributo at2 = it2.second;
        if ((par1.first == par2.first) && (par1.second != par2.second) && (at1.escopo == at2.escopo)) {
          correto = false;
          msgErro = "A variável "+par1.first+" foi declarada duas vezes com tipos diferentes no mesmo escopo.";
          break;
        }
      }
    }
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

PRINTSTAT: PR EXPRESSION {}
  ;

READSTAT: RD LVALUE {}
  ;

RETURNSTAT: RET {}
  ;

IFSTAT: IF P1 EXPRESSION P2 STATEMENT {}
  | IFE P1 EXPRESSION P2 STATEMENT ELS STATEMENT {}
  ;

FORSTAT: FOR {expressaoLoop = true; escopoLoop = true;} P1 ATRIBSTAT PV EXPRESSION PV ATRIBSTAT P2 {expressaoLoop = false; expressao = ""; tipoExpressao = "";} STATEMENT {expressaoLoop = false; escopoLoop = false;}
  ;

STATELIST: STATEMENT STATELIST {}
  | STATEMENT {}
  ;

ALLOCEXPRESSION: NEW INT CL1 NUMEXPRESSION CL2 {}
  | NEW FLT CL1 NUMEXPRESSION CL2 {}
  | NEW STR CL1 NUMEXPRESSION CL2 {}
  ;

EXPRESSION: NUMEXPRESSION MER NUMEXPRESSION {}
  | NUMEXPRESSION MAR NUMEXPRESSION {}
  | NUMEXPRESSION MEI NUMEXPRESSION {}
  | NUMEXPRESSION MAI NUMEXPRESSION {}
  | NUMEXPRESSION CMP NUMEXPRESSION {}
  | NUMEXPRESSION DIF NUMEXPRESSION {}
  | NUMEXPRESSION {}
  ;

NUMEXPRESSION: TERM NTERM {
    if (!expressaoLoop) {
      if (op != "") {
        expressao = op+expressao;
      }
      expressoes.push_back(expressao);
      expressaoPronta = expressao;
      expressao = "";
      tipoExpressao = "";
    }
  }
  ;

NTERM: %empty {}
  | ADD TERM NTERM {op += "+";}
  | SUB TERM NTERM {op += "-";}
  ;

TERM: UNARYEXPR MUL UNARYEXPR {
    expressao += "*"+expAux;
    expAux = "";
  }
  | UNARYEXPR DIV UNARYEXPR {expressao += "/"+expAux; expAux = "";}
  | UNARYEXPR PRC UNARYEXPR {expressao += "%"+expAux; expAux = "";}
  | UNARYEXPR {expressao += expAux; expAux = "";}
  ;

UNARYEXPR: ADD AFACTOR {} // Produção para sinal +
  | SUB SFACTOR {} // Produção para sinal -
  | FACTOR {} // Produção sem sinal
  ;

AFACTOR: ICT {
    expAux += "+"+std::string(yytext);
    if (tipoExpressao != "int") {
      correto = false;
      if (msgErro == "") {
        msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
      }
    }
  }
  | FCT {
    expAux += "+"+std::string(yytext);
    if (tipoExpressao != "float") {
      correto = false;
      if (msgErro == "") {
        msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
      }
    }
  }
  | SCT {
    expAux += "+"+std::string(yytext);
    if (tipoExpressao != "string") {
      correto = false;
      if (msgErro == "") {
        msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
      }
    }
  }
  | NL {}
  | LVALUE {}
  | P1 NUMEXPRESSION P2 {}
  ;

SFACTOR: ICT {
    expAux += "-"+std::string(yytext);
    if (tipoExpressao != "int") {
      correto = false;
      if (msgErro == "") {
        msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
      }
    }
  }
  | FCT {
    expAux += "-"+std::string(yytext);
    if (tipoExpressao != "float") {
      correto = false;
      if (msgErro == "") {
        msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
      }
    }
  }
  | SCT {
    expAux += "-"+std::string(yytext);
    if (tipoExpressao != "string") {
      correto = false;
      if (msgErro == "") {
        msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
      }
    }
  }
  | NL {}
  | LVALUE {}
  | P1 NUMEXPRESSION P2 {}
  ;

FACTOR: ICT {
    expAux += yytext;
    if (tipoExpressao != "int") {
      correto = false;
      if (msgErro == "") {
        msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
      }
    }
  }
  | FCT {
    expAux += yytext;
    if (tipoExpressao != "float") {
      correto = false;
      if (msgErro == "") {
        msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
      }
    }
  }
  | SCT {{op += "+";}
    expAux += yytext;
    if (tipoExpressao != "string") {
      correto = false;
      if (msgErro == "") {
        msgErro = "O valor na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" tem um tipo diferente do tipo da expressão.";
      }
    }
  }
  | NL {}
  | LVALUE {}
  | P1 NUMEXPRESSION P2 {}
  ;

LVALUE: ID {
    for (auto const& it: TabelaSimbolo::instancia()->getTabela()) {
      std::pair<std::string, std::string> par = it.first;
      Atributo at = it.second;
      if ((par.first == yytext) && (at.escopo == escopoEspressao)) {
        tipoExpressao = par.second;
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
  return correto;
}

std::vector<std::string> arvoreExpressao() {
  return expressoes;
}

std::string mensagemErro() {
  return msgErro;
}
