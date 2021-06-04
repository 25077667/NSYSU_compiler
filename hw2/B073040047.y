%define parse.error verbose
%{
#include <stdio.h>
#include "lib/symbol_table.h"
int yylex();
void yyerror(const char *s);
%}

%token AND BOOLEAN CHAR CLASS ELSE EQ FINAL FLOAT FOR GE ID IF INT LE MAIN MM NE NEW INT_L FLOAT_L OR PP PRINT RETURN STATIC STR VOID WHILE

%%
classes: | classes class;

class: CLASS generic_id '{'{push();} fields methods '}'{pop();};

fields: declaration_star;
methods: 
| methods type generic_id '(' id_list_star ')' compound
| methods MAIN '(' id_list_star ')' compound
| methods VOID MAIN '(' id_list_star ')' compound;

id_list_star:|id_list;

compound: '{'{push();} declaration_star statement_star '}'{pop();} 
;

declaration_star: 
| declaration_star specifier  type      id_list      ';'
| declaration_star specifier  type      id_list_init ';'
| declaration_star FINAL      type      id_list_init ';'
| declaration_star specifier  arr_type  arr_init     ';'
;

specifier: | STATIC;

id_list: generic_id
| id_list ',' generic_id
| id_list_init
| id_list ',' id_list_init
;

id_list_init: generic_id '=' const_expr
| id_list_init ',' generic_id '=' const_expr 
;

generic_id:  ID | generic_id'[' INT_L ']' | generic_id'.'ID;

type: INT 
| FLOAT
| CHAR
| BOOLEAN
| VOID
;

const_expr: INT_L
| FLOAT_L
| STR
| generic_id 
| const_expr Infixop const_expr
;

Infixop: '+' | '-' | '*' | '/' | '%' | '>' | '<' | '&' | '|' | LE | GE | EQ | NE | AND | OR ;

arr_type: INT'['']'
| FLOAT'['']'
| CHAR'['']'
| BOOLEAN'['']'
;

arr_init: generic_id '=' NEW type'[' INT_L ']';

statement_star:
| statement_star compound
| statement_star simple ';'
| statement_star conditional
| statement_star loop
| statement_star return ';'
| statement_star call ';'
| statement_star ';'
;

simple: generic_id '=' expr ';' 
| PRINT '(' expr ')' ';'
| generic_id PP ';'
| generic_id MM ';'
| expr ';'
| ';'
;

expr: term
| expr '+' term
| expr '-' term
;

term: factor
| term '*' factor
| term '/' factor;

factor: const_expr
| '(' expr ')'
| PrefixOp generic_id
| generic_id PostfixOp
| call 
;

PrefixOp: PP | MM | '+' | '-';
PostfixOp: PP | MM ;

conditional: IF '(' bool_expr ')' simple ELSE simple
| IF '(' bool_expr ')' compound ELSE simple
| IF '(' bool_expr ')' compound ELSE compound
| IF '(' bool_expr ')' simple ELSE compound
;

bool_expr: expr;

loop: WHILE '(' bool_expr ')' simple
| WHILE '(' bool_expr ')' compound
| FOR '(' ForInitOpt ';' bool_expr ';' ForUpdateOpt ')' simple
| FOR '(' ForInitOpt ';' bool_expr ';' ForUpdateOpt ')' compound
;

ForInitOpt:
| id_list_init
| INT id_list_init
;

ForUpdateOpt: 
| generic_id PP | generic_id MM
;

return: RETURN expr ';' ;

call: generic_id '(' expr_list ')' ';'
;

expr_list: expr
| expr ',' expr_list
;

%%
int main() {
    yyparse();
    return 0;
}
