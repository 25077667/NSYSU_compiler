%define parse.error verbose
%define parse.trace
%{
#include <stdio.h>
#include "lib/symbol_table.h"
int yylex();
void yyerror(const char *s);
extern char tok[80];
#define DUP_ID "duplicate id.\n"
#define MISS_SEMI "Missing semicolum.\n"
#define show_errmsg(x) fprintf(stderr, x)

#define chk_dupid do{int res = insert(tok); if (res < 0) show_errmsg(DUP_ID);} while(0)
%}

%token AND BOOLEAN CHAR CLASS ELSE EQ FINAL FLOAT FOR GE ID IF INT LE MAIN MM NE NEW INT_L FLOAT_L OR PP PRINT RETURN STATIC STR VOID WHILE

%%
classes: | classes class;

class: CLASS ID '{'{push();} fields methods '}'{pop();};

// corss_f_m: fields | methods | corss_f_m fields | corss_f_m methods;

fields: declaration_star;
methods: 
    | methods type ID '(' id_list_star ')' compound
    | methods MAIN '(' id_list_star ')' compound
    | methods VOID MAIN '(' id_list_star ')' compound
    ;

id_list_star:|id_list;

compound: '{'{push();} declaration_star statement_star '}'{pop();} ;

declaration_star:
    | declaration_star spec_decl__  ';'
    | declaration_star final_decl__ ';'
    ;

spec_decl__: spec_decl_chk__ id_list
    | spec_decl_chk__ arr_init
    | spec_decl_chk__ new_obj // For the class had not decl.
    ;

spec_decl_chk__: spec_type__ {chk_dupid;};

final_decl__: final_decl_chk__ id_list_init // For the class had not decl.
    | final_decl_chk__ new_obj
    ;

final_decl_chk__: final_type__ {chk_dupid;} ;

spec_type__: specifier type;
final_type__: FINAL type;

specifier: | STATIC;

id_list: init_or_not__
    | id_list ',' init_or_not__
    ;

init_or_not__: generic_id | id_list_init;

id_list_init: generic_id '=' const_expr
    | id_list_init ',' generic_id '=' const_expr 
    ;

new_obj: ID '=' NEW ID '(' tuple ')';

tuple: | tuple INT_L | tuple FLOAT_L | tuple STR;

generic_id:  ID | generic_id'[' INT_L ']' | generic_id'.'ID;

type: type '[' ']'
    | INT 
    | FLOAT
    | CHAR
    | BOOLEAN
    | VOID
    | ID
    ;

const_expr: INT_L
    | FLOAT_L
    | STR
    | generic_id 
    | const_expr Infixop const_expr
    ;

Infixop: '+' | '-' | '*' | '/' | '%' | '>' | '<' | '&' | '|' | LE | GE | EQ | NE | AND | OR ;

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
    | term '/' factor
    ;

factor: const_expr
    | '(' expr ')'
    | PrefixOp generic_id
    | generic_id PostfixOp
    | call
    ;

PrefixOp: PP | MM | '+' | '-';
PostfixOp: PP | MM ;

conditional: if_simple__ simple
    | if_simple__ compound
    | if_compound__ simple
    | if_compound__ compound
    ;

if_expr__: IF '(' bool_expr ')';

if_simple__: if_expr__ simple 
    | if_simple__ ELSE
    ;

if_compound__: if_expr__ compound
    | if_compound__ ELSE
    ;

bool_expr: expr;

loop: while_expr__     simple
    | while_expr__     compound
    | for_expr__       simple
    | for_expr__       compound
    ;

while_expr__: WHILE '(' bool_expr ')'; 
for_expr__  : FOR '(' ForInitOpt ';' bool_expr ';' ForUpdateOpt ')';

ForInitOpt:
    | id_list_init
    | INT id_list_init
    ;

ForUpdateOpt: 
    | generic_id PP | generic_id MM
    ;

return: RETURN expr ';' ;

call: generic_id '(' expr_list ')' ';';

expr_list: expr
    | expr ',' expr_list
    ;

%%
int main() {
    yyparse();
    return 0;
}
