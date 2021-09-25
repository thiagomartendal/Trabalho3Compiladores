%{
  #include <vector>
  #include <string>
  #include <algorithm>
  #include "tabela_simbolo.h"
  #include "sintatico.tab.h"

  int yycolumn = 1;
  int start_line = 1, start_column = 1;
  int tokenAnterior = -1;
  int escopoGeral;
  int auxEscopo = -1;
  int escopoFuncao = -1;
  std::vector<std::string> funcLex;
  std::string tokenLido;
  std::string tipoVariavel = "";
  std::string erroInicializacao = "";
  std::string erroDeclaracaoMultipla = "";
  bool definicaoFuncao = false;
  bool atribuicaoValor = false;

  #define YY_USER_ACTION                                                   \
    start_line = prev_yylineno; start_column = yycolumn;                   \
    if (yylineno == prev_yylineno) yycolumn += yyleng;                     \
    else {                                                                 \
      for (yycolumn = 1; yytext[yyleng - yycolumn] != '\n'; ++yycolumn) {} \
      prev_yylineno = yylineno;                                            \
    }

  extern "C" {
    std::string erroNaInicializacao();
    std::string erroMultiplaDeclaracao();
    int coluna(void);
    const char* tokenAtual(void);
  }
%}

%option noyywrap
%option yylineno

%%
  int prev_yylineno = yylineno;
"new" {tokenLido = "NEW"; tokenAnterior = NEW; return NEW;}
"def" {tokenLido = "DF"; tokenAnterior = DF; definicaoFuncao = true; escopoFuncao++; return DF;}
"read" {tokenLido = "RD"; return RD;}
"print" {tokenLido = "PR"; return PR;}
"null" {tokenLido = "NL"; return NL;}
"int" {
  tokenLido = "INT";
  if (tokenAnterior != NEW) {
    tipoVariavel = "int";
  } else {
    tokenAnterior = -1;
  }
  return INT;
}
"float" {
  tokenLido = "FLT";
  if (tokenAnterior != NEW) {
    tipoVariavel = "float";
  } else {
    tokenAnterior = -1;
  }
  return FLT;
}
"string" {
  tokenLido = "STR";
  if (tokenAnterior != NEW) {
    tipoVariavel = "string";
  } else {
    tokenAnterior = -1;
  }
  return STR;
}
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
"=" {tokenLido = "ATR"; atribuicaoValor = true; return ATR;}
">" {tokenLido = "MAR"; return MAR;}
"<" {tokenLido = "MER"; return MER;}
"==" {tokenLido = "CMP"; return CMP;}
">=" {tokenLido = "MAI"; return MAI;}
"<=" {tokenLido = "MEI"; return MEI;}
"!=" {tokenLido = "DIF"; return DIF;}
"(" {tokenLido = "P1"; return P1;}
")" {tokenLido = "P2"; return P2;}
"{" {tokenLido = "CV1"; auxEscopo++; escopoGeral = auxEscopo+1; return CV1;}
"}" {tokenLido = "CV2"; escopoGeral--; return CV2;}
"[" {tokenLido = "CL1"; return CL1;}
"]" {tokenLido = "CL2"; return CL2;}
"," {tokenLido = "VI"; return VI;}
";" {tokenLido = "PV"; return PV;}
[a-zA-Z_][a-zA-Z0-9_]* {
  Posicao p = {yylineno, coluna()};
  if (definicaoFuncao) {
    definicaoFuncao = false;
    bool funcaoRepetida = false;
    for (auto const& it: TabelaSimbolo::instancia()->getTabela()) {
      auto const& par1 = it.first;
      auto const& par2 = par1.second;
      if ((par1.first == yytext) && (par2.first == "função") && (it.second.escopos.find(escopoGeral) != it.second.escopos.end())) {
        funcaoRepetida = true;
        break;
      }
    }
    if (funcaoRepetida) {
      if (erroDeclaracaoMultipla == "") {
        erroDeclaracaoMultipla = "A função "+std::string(yytext)+" foi declarada duas vezes no mesmo escopo.";
      }
    } else {
      TabelaSimbolo::instancia()->inserir(yytext, p, escopoGeral, escopoFuncao, "função");
    }
  } else {
    if (tipoVariavel != "") {
      std::map<std::pair<std::string, std::pair<std::string, int>>, Atributo>::iterator it = TabelaSimbolo::instancia()->getTabela().find(std::make_pair(yytext, std::make_pair(tipoVariavel, escopoFuncao)));
      if ((it != TabelaSimbolo::instancia()->getTabela().end()) && (it->second.escopos.find(escopoGeral) != it->second.escopos.end()) && (!atribuicaoValor)) {
        if (erroDeclaracaoMultipla == "") {
          erroDeclaracaoMultipla = "A variável "+std::string(yytext)+" foi declarada duas vezes no mesmo escopo.";
        }
      } else {
        TabelaSimbolo::instancia()->inserir(yytext, p, escopoGeral, escopoFuncao, tipoVariavel);
        if (atribuicaoValor) {
          atribuicaoValor = false;
        }
      }
      tipoVariavel = "";
    } else {
      if (!TabelaSimbolo::instancia()->inserir(yytext, p, escopoGeral, escopoFuncao)) {
        if ((!definicaoFuncao) && (erroInicializacao == "")) {
          erroInicializacao = "A variável "+std::string(yytext)+" na linha "+std::to_string(yylineno)+" e coluna "+std::to_string(coluna())+" foi utilizada antes de ser declarada.";
        }
      }
    }
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

std::string erroNaInicializacao() {
  return erroInicializacao;
}

std::string erroMultiplaDeclaracao() {
  return erroDeclaracaoMultipla;
}
