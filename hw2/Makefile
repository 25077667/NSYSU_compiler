CC= gcc
LEX= flex
YACC= bison

LEX_RULE= B073040047.l
YACC_RULE= B073040047.y
all: clean yacc lex
	${CC} B073040047.tab.o lex.o lib/libsymbol_table.a -lfl -ly -lstdc++ -g -static -o my_yacc.elf

clean:
	rm -rf lib/build B073040047.tab.o lex.o my_yacc.elf lex.c
	rm -f B073040047.tab.c B073040047.tab.h B073040047.output B073040047.dot B073040047.jpg

lex: ${LEX_RULE}
	${LEX} -o lex.c ${LEX_RULE}
	${CC} -c -g lex.c

yacc: ${YACC_RULE}
	${YACC} -g -vd ${YACC_RULE}
	${CC} -c -g B073040047.tab.c

dot: yacc
	dot -T jpg B073040047.dot -o B073040047.jpg

test: all
	for i in $$(seq 1 6); do
		./my_yacc.elf < Testfile/Test$$i.java;
		echo;
	done
