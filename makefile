instalar-flex-bison:
	sudo apt-get install flex bison

compilar:
	flex lexico.l
	bison -d sintatico.y
	g++ main.cpp entrada.cpp analise_lexica.cpp tabela_simbolo.cpp lex.yy.c sintatico.tab.c -lfl -o Main

programa1_lexico:
	./Main -l programas/programa-lcc-1.lcc

programa2_lexico:
	./Main -l programas/programa-lcc-2.lcc

programa3_lexico:
	./Main -l programas/programa-lcc-3.lcc

programa4_lexico:
	./Main -l programas/expressao.lcc

programa5_lexico:
	./Main -l programas/expressao2.lcc

programa6_lexico:
	./Main -l programas/testeEscopo.lcc

programa7_lexico:
	./Main -l programas/geracaoLoop.lcc

programa8_lexico:
	./Main -l programas/geracaoIf.lcc

programa9_lexico:
	./Main -l programas/geracaoExpressao.lcc

programa1_sintatico:
	./Main -s programas/programa-lcc-1.lcc

programa2_sintatico:
	./Main -s programas/programa-lcc-2.lcc

programa3_sintatico:
	./Main -s programas/programa-lcc-3.lcc

programa4_sintatico:
	./Main -s programas/expressao.lcc

programa5_sintatico:
	./Main -s programas/expressao2.lcc

programa6_sintatico:
	./Main -s programas/testeEscopo.lcc

programa7_sintatico:
	./Main -s programas/geracaoLoop.lcc

programa8_sintatico:
	./Main -s programas/geracaoIf.lcc

programa9_sintatico:
	./Main -s programas/geracaoExpressao.lcc
