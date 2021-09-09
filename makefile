compilar:
	flex lexico.l
	bison -d sintatico.y
	g++ main.cpp entrada.cpp analise_lexica.cpp tabela_simbolo.cpp lex.yy.c sintatico.tab.c -lfl -o Main
