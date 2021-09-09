%{
  #include <vector>
  #include <string>
  #include <algorithm>
  #include "tabela_simbolo.h"
  #include "sintatico.tab.h"

  int yycolumn = 1;
  int start_line = 1, start_column = 1;
  int tokenAnterior = -1;
  int escopoAtual = -1;
  std::vector<std::string> funcLex;
  std::string tokenLido;
  std::string tipoVariavel = "";

  #define YY_USER_ACTION                                                   \
    start_line = prev_yylineno; start_column = yycolumn;                   \
    if (yylineno == prev_yylineno) yycolumn += yyleng;                     \
    else {                                                                 \
      for (yycolumn = 1; yytext[yyleng - yycolumn] != '\n'; ++yycolumn) {} \
      prev_yylineno = yylineno;                                            \
    }

  extern "C" {
    int coluna(void);
    const char* tokenAtual(void);
  }
%}

%option noyywrap
%option yylineno

%%
  int prev_yylineno = yylineno;
"new" {tokenLido = "NEW"; return NEW;}
"def" {tokenLido = "DF"; tokenAnterior = DF; return DF;}
"read" {tokenLido = "RD"; return RD;}
"print" {tokenLido = "PR"; return PR;}
"null" {tokenLido = "NL"; return NL;}
"int" {tokenLido = "INT"; tipoVariavel = "int"; return INT;}
"float" {tokenLido = "FLT"; tipoVariavel = "float"; return FLT;}
"string" {tokenLido = "STR"; tipoVariavel = "string"; return STR;}
"if" {tokenLido = "IF"; return IF;}
"ifelse" {tokenLido = "IFE"; return IFE;}
"else" {tokenLido = "ELS"; return ELS;}
"for" {tokenLido = "FOR"; return FOR;}
"break" {tokenLido = "BRK"; return BRK;}
"return" {tokenLido = "RET"; return RET;}
"+" {tokenLido = "ADD"; return ADD;}
"-" {tokenLido = "SUB"; return SUB;}
"*" {tokenLido = "MUL"; return MUL;}
"/" {tokenLido = "DIV"; return DIV;}
"%" {tokenLido = "PRC"; return PRC;}
"=" {tokenLido = "ATR"; return ATR;}
">" {tokenLido = "MAR"; return MAR;}
"<" {tokenLido = "MER"; return MER;}
"==" {tokenLido = "CMP"; return CMP;}
">=" {tokenLido = "MAI"; return MAI;}
"<=" {tokenLido = "MEI"; return MEI;}
"!=" {tokenLido = "DIF"; return DIF;}
"(" {tokenLido = "P1"; return P1;}
")" {tokenLido = "P2"; return P2;}
"{" {tokenLido = "CV1"; escopoAtual++; return CV1;}
"}" {tokenLido = "CV2"; escopoAtual--; return CV2;}
"[" {tokenLido = "CL1"; return CL1;}
"]" {tokenLido = "CL2"; return CL2;}
"," {tokenLido = "VI"; return VI;}
";" {tokenLido = "PV"; return PV;}
[a-zA-Z_][a-zA-Z0-9_]* {
  Posicao p = {yylineno, coluna()};
  if (tipoVariavel != "") {
    TabelaSimbolo::instancia()->inserir(yytext, p, tipoVariavel);
    TabelaSimbolo::instancia()->inserirEscopo(yytext, escopoAtual, tipoVariavel);
    tipoVariavel = "";
  } else {
    TabelaSimbolo::instancia()->inserir(yytext, p);
  }
  if (tokenAnterior == DF) {
    tokenAnterior = -1;
    funcLex.push_back(yytext);
    tokenLido = "IDF";
    return IDF;
  }
  if (std::find(funcLex.begin(), funcLex.end(), yytext) != funcLex.end()) {
    tokenLido = "IDF";
    return IDF;
  }
  tokenLido = "ID";
  return ID;
}
[[:digit:]]+ {tokenLido = "ICT"; return ICT;}
[[:digit:]]+\.[[:digit:]]+ {tokenLido = "FCT"; return FCT;}
\"(([^\"]|\\\")*[^\\])?\" {tokenLido = "SCT"; return SCT;}
[ \n\t] {;}
. {tokenLido = "ERR"; return ERR;}
<<EOF>> { static int once = 0; return once++ ? 0 : '\n'; }
%%

int coluna() {
  return start_column;
}

const char* tokenAtual() {
  return tokenLido.c_str();
}
