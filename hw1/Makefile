CC= gcc
CXX= g++
LEX= flex

all: clean lex
	${CXX} lex.o lib/libsymbol_table.a -lfl -o my_lex.elf

clean:
	rm -rf lib/build lex.o my_lex.elf lex.c

lex: demo.l
	${LEX} -o lex.c demo.l
	${CC} -c lex.c

test: all
	./my_lex.elf < TestFile_Lab1_2021/Test1.java
	./my_lex.elf < TestFile_Lab1_2021/Test2.java
	./my_lex.elf < TestFile_Lab1_2021/Test3.java