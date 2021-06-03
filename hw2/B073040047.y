%define parse.error verbose
%{
#include <stdio.h>
#include "lib/symbol_table.h"
int yylex();
void yyerror(const char *s);
%}

%token AND BOOLEAN CHAR CLASS ELSE EQ FINAL FLOAT FOR GE ID IF INT LE MAIN MM NE NEW INT_L FLOAT_L OR PP PRINT RETURN STATIC STR VOID WHILE

%%
classes : 
| classes class;


class : 
CLASS ID '{' { push(); } fields methods { pop();} '}'
| CLASS ID '{' { push(); } fields { pop();} '}'
| CLASS ID '{' { push(); } methods { pop();} '}'
;

fields: declarations;
methods: type ID '(' id_list_star ')' compound;

id_list_star:|id_list;

compound:  '{' { push(); } { pop();} '}'
|  '{' { push(); } declarations { pop();} '}'
|  '{' { push(); } statement { pop();} '}'
|  '{' { push(); } declarations statement { pop();} '}'
;

declarations: specifier type id_list ';'
| specifier type id_list_init ';'
| FINAL type id_list_init ';'
| specifier arr_type arr_init ';'
;

specifier: | STATIC;

id_list: ID
| ID ',' id_list
| id_list_init
| id_list_init ',' id_list
;

id_list_init: ID '=' const_expr
| ID '=' const_expr ',' id_list_init
;

type: INT 
| FLOAT
| CHAR
| BOOLEAN
| VOID
;

const_expr: INT_L
| FLOAT_L
| INT_L Infixop INT_L
| INT_L Infixop FLOAT_L
| FLOAT_L Infixop INT_L
| FLOAT_L Infixop FLOAT_L
;

Infixop: '+' | '-' | '*' | '/' | '%' | '>' | '<' | '&' | '|'
| '<''=' | '>''=' | '=''=' | '!''=' | '&''&' | '|''|' ;

arr_type: INT'['']'
| FLOAT'['']'
| CHAR'['']'
| BOOLEAN'['']'
;

arr_init: '=' NEW type'[' INT_L ']';

statement: compound
| simple ';'
| conditional ';'
| loop ';'
| return ';'
| call ';'
| ';'
;

simple: name '=' expr ';' 
| PRINT '(' expr ')' ';'
| name PP ';'
| name MM ';'
| expr ';'
| ';'
;

name: ID | name'.'ID;

expr: term
| expr '+' term
| expr '-' term
;

term: factor
| factor '*' factor
| factor '/' factor;

factor: ID
| const_expr
| '(' expr ')'
| PrefixOp ID
| ID PostfixOp
| call 
;

PrefixOp: PP | MM | '+' | '-';
PostfixOp: PP | MM ;

conditional: IF '(' bool_expr ')' simple ELSE simple
| IF '(' bool_expr ')' compound ELSE simple
| IF '(' bool_expr ')' compound ELSE compound
| IF '(' bool_expr ')' simple ELSE compound
;

bool_expr: expr Infixop expr;

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
| ID PP | ID MM
;

return: RETURN expr ';' ;

call: name '(' expr_list ')' ';'
;

expr_list: expr
| expr ',' expr_list
;

%%
int main() {
    yyparse();
    return 0;
}
