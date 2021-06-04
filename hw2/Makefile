CC= gcc
LEX= flex
YACC= bison

LEX_RULE= B073040047.l
YACC_RULE= B073040047.y
all: clean yacc lex 
	${CC} B073040047.tab.o lex.o lib/libsymbol_table.a -lfl -ly -lstdc++ -static -o my_yacc.elf

clean:
	rm -rf lib/build B073040047.tab.o lex.o my_yacc.elf lex.c B073040047.tab.c B073040047.tab.h B073040047.output

lex: ${LEX_RULE}
	${LEX} -o lex.c ${LEX_RULE}
	${CC} -c lex.c

yacc: ${YACC_RULE}
	${YACC} -v -d ${YACC_RULE}
	${CC} -c B073040047.tab.c

test: all
	for i in $$(seq 1 6); do
		./my_yacc.elf < Testfile/Test$$i.java;
		echo;
	done
