%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "btoc.h"

tabela_simbolos* sym_table = NULL;
%}
%error-verbose 


%union {
    int iValue;                 /* valor inteiro */
    char *sValue;               /* valor strings */
    nodeType *nPtr;             /* ponteiro para o noh */
};

%token <iValue> INT
%token <sValue> VAR
%token <sValue> STRING
%token UNTIL WHILE IF IN ECHO DO DONE FOR READ THEN FUNCTION CASE ESAC ELSE FI ELIF 
%nonassoc IFX
%nonassoc NX

%type <nPtr> command pipeline
%type <nPtr> compound_list list1 
%type <nPtr> shell_command 
%type <nPtr> for_command
%type <nPtr> expr
%type <iValue> list_terminator
%type <nPtr> function_def group_command if_command elif_clause
%type <nPtr> word 
%type <nPtr> case_command case_clause case_clause_sequence pattern_list pattern
%type <nPtr> number 

%start inputunit

%left GE_OP GT_OP LE_OP LT_OP EQ_OP NE_OP INC_OP DEC_OP AND_OP OR_OP '>' '<' LOOPFOR SEMI_SEMI
%left '+' '-'
%left '*' '/'
%left ';' '\n' 
%right '|'

%%

inputunit
        : inputunit pipeline              { gera_codigo($2, sym_table); freeNode($2); }
        | /* NULL */
        ;

number
        : INT                            { $$ = num($1);}
        ;

word
        : VAR                            { $$ = id('v',$1);if (!search(sym_table,$1)) add($1,'v');}
        | STRING                         { $$ = id('s',$1);}
        ;

command
        : shell_command                  { $$ = $1; }
        | function_def                   { $$ = $1; }
        | list_terminator                { $$ = opr(';',2,NULL,NULL); }
        ;

shell_command
        : for_command                    { $$ = $1; }
        | if_command                     { $$ = $1; }
        | case_command                   { $$ = $1; }
        | expr linebreak                 { $$ = $1; }
        | ECHO linebreak expr list_terminator { $$ = opr(ECHO, 1, $3); }
        | READ linebreak expr list_terminator { $$ = opr(READ, 1, $3); }
        | VAR '=' expr                   { $$ = opr('=', 2, id('v',$1), $3)
                                         ;if (!search(sym_table,$1)) add($1,'v'); }
        | '(' '(' VAR '=' expr ')' ')'   { $$ = opr('=', 2, id('v',$3), $5)
                                         ;if (!search(sym_table,$3)) add($3,'v'); }
        | WHILE '[' expr ']' list_terminator DO compound_list DONE   { $$ = opr(WHILE, 2, $3, $7); }
        | UNTIL '[' expr ']' list_terminator DO compound_list DONE   { $$ = opr(UNTIL, 2, $3, $7); }
        ;

for_command
        : FOR '(''(' word '=' number ';' expr ';' expr ')'')' list_terminator DO compound_list DONE  { $$ = opr(FOR, 5, $4, $6, $8, $15, $10); }
        | FOR '(''(' word '=' number ';' expr ';' expr ')'')' group_command  { $$ = opr(FOR, 5, $4, $6, $8, $13, $10); }
        | FOR word IN '{' number LOOPFOR number '}' list_terminator DO compound_list DONE  {
                                         $$ = opr(FOR, 4, $2,$5,$7,$11);}
        | FOR word IN '{' number LOOPFOR number '}' list_terminator group_command  {
                                         $$ = opr(FOR, 4, $2,$5,$7,$10);}
        ;

if_command
        : IF '[' expr ']' list_terminator THEN compound_list FI %prec IFX      
                                         { $$ = opr(IF, 2, $3, $7); }
        | IF '[' expr ']' list_terminator THEN compound_list ELSE compound_list FI
                                         { $$ = opr(IF, 3, $3, $7, $9);}
        | IF '[' expr ']' list_terminator THEN compound_list elif_clause FI
                                         { $$ = opr(IF, 4, $3, $7, $8,NULL);}
        ;

elif_clause
        : ELIF '[' expr ']' list_terminator THEN compound_list %prec IFX
                                         { $$ = opr(ELIF, 2, $3, $7); }
        | ELIF '[' expr ']' list_terminator THEN compound_list ELSE compound_list
                                         { $$ = opr(ELIF, 3, $3, $7, $9);}
        | ELIF '[' expr ']' list_terminator THEN compound_list elif_clause
                                         { $$ = opr(ELIF, 4, $3, $7, $8,NULL);}
        ;

case_command
        : CASE word linebreak IN case_clause_sequence linebreak ESAC
                                         { $$ = opr(CASE,4,  $2, $5, NULL, NULL); }
        | CASE word linebreak IN case_clause ESAC
                                         { $$ = opr(CASE,4,  $2, $5, NULL, NULL); }
        ;

case_clause
        :  pattern_list        { $$ = $1; }
        |  case_clause_sequence pattern_list  { $$ = opr(CASE, 3 , $1, $2, NULL); }
        ;

pattern_list
        : linebreak pattern ')' compound_list        { $$ = opr(CASE, 2 , $2, $4); }
        | linebreak pattern ')' linebreak         { $$ = opr(CASE, 1 , $2); }
        | linebreak '(' pattern ')' compound_list    { $$ = opr(CASE, 2 , $3, $5); }
        | linebreak '(' pattern ')' linebreak     { $$ = opr(CASE, 1 , $3); }
        ;

case_clause_sequence
        :  pattern_list SEMI_SEMI        { $$ = $1; }
        |  case_clause_sequence pattern_list SEMI_SEMI { $$ = opr(CASE, 3 , $1, $2, NULL); }
        ;

pattern
        :  number                          { $$ = $1; }
        |  '*'                             { $$ = opr('*',1,NULL); }
        |  pattern '|' number              { $$ = opr('|',2,$1,$3); }
        ;


function_def
        : FUNCTION VAR linebreak group_command   { $$ = opr(FUNCTION, 2, id('f',$2), $4)
                                         ;if (!search(sym_table,$2)) add($2,'f'); }
        ;

group_command
        : linebreak '{' compound_list '}' linebreak                 {$$ = $3;}
        ;

compound_list
        : linebreak list1             { $$ = $2; }
        ;

list1
        : list1 linebreak pipeline       { $$ = opr(';', 2, $1, $3); }
        | pipeline                          { $$ = $1; }
        ;

list_terminator
        : '\n'                  { $$ = '\n'; }
        | ';'                   { $$ = ';'; }
        ;

newline_list
        : '\n' 
        | newline_list '\n' 
        ;

linebreak 
        : newline_list %prec NX
        | %prec NX
        ;

expr
        : word                  { $$ = $1; }
        | number                { $$ = $1; }
        | expr '+' expr         { $$ = opr('+', 2, $1, $3); }
        | expr INC_OP           { $$ = opr(INC_OP, 1, $1); }
        | expr '-' expr         { $$ = opr('-', 2, $1, $3); }
        | expr DEC_OP           { $$ = opr(DEC_OP, 1, $1); }
        | expr '*' expr         { $$ = opr('*', 2, $1, $3); }
        | expr '/' expr         { $$ = opr('/', 2, $1, $3); }
        | expr '<' expr         { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr         { $$ = opr('>', 2, $1, $3); }
        | expr GE_OP expr       { $$ = opr(GE_OP, 2, $1, $3); }
        | expr GT_OP expr       { $$ = opr('>', 2, $1, $3); }
        | expr LE_OP expr       { $$ = opr(LE_OP, 2, $1, $3); }
        | expr LT_OP expr       { $$ = opr('<', 2, $1, $3); }
        | expr NE_OP expr       { $$ = opr(NE_OP, 2, $1, $3); }
        | expr EQ_OP expr       { $$ = opr(EQ_OP, 2, $1, $3); }
        | expr AND_OP expr      { $$ = opr(AND_OP,2, $1, $3); }
        | expr OR_OP expr       { $$ = opr(OR_OP,2, $1, $3); }
        | '(''(' expr ')'')'    { $$ = $3; }
        ;

pipeline
        : pipeline '|' command    {$$ = opr('|',2,$1,$3);}
        | command linebreak      {$$ = $1;}
        ;

%%

nodeType *num(int valor) {
    nodeType *p;

    /* Aloca noh na memoria */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* informacoes do inteiro */
    p->type = typeNum;
    p->num.value = valor;

    return p;
}

nodeType *id(char type, char *s) {
    nodeType *p;

    /* Aloca noh na memoria */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    
    if (type == 's'){
        int i;
        int l;
        l = strlen(s);
        for (i=0;i<=l;i++){
            if (s[i] == '$'){
                s[i] = '%';
                s[i+1] = 'd';
            }
        }
    }

    /* informacoes do identidicador */
    p->type = typeId;
    p->id.type = type;
    p->id.value = s;
    
    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* Aloca noh na memoria */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    if ((p->opr.op = malloc(nops * sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* informacoes do operador */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;
    tabela_simbolos* t = sym_table;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
		free (p->opr.op);
    }
    free (p);

}

tabela_simbolos *add(char *valor, char tipo) {
    tabela_simbolos* s = malloc(sizeof(tabela_simbolos));
    s->hasValue = 0;
    s->type = tipo;
    s->value = strdup(valor);

    s->next = sym_table;
    sym_table = s;

    return s;
}

tabela_simbolos *search(tabela_simbolos *st, char *name) {
    tabela_simbolos* sym = st;
    while (sym) {
        if (sym->value && strcmp(sym->value, name) == 0) {
            return sym;
        }
    sym = sym->next;
    }
    return NULL;
}

void inicializa_ts(tabela_simbolos *st) {
    tabela_simbolos* sym = st;
    while (sym) {
        if (sym->value) {
            printf("\n int %s", sym->value);
        }
    sym = sym->next;
    }
}


void imprime_ts(tabela_simbolos *st) {
    tabela_simbolos* sym = st;
    while (sym) {
        if (sym->value) {
            printf("\n TS: %s, %c, %d", sym->value, sym->type, sym->hasValue);
        }
    sym = sym->next;
    }
}

void initSym(tabela_simbolos* ptrSym){
    ptrSym->type = 0;
    ptrSym->value = 0;
    ptrSym->hasValue = 0;
}

void apaga_tf(void) {
    tabela_simbolos* temp = sym_table;
    for (; temp != NULL; temp = sym_table) {
        sym_table = temp->next;

        if (temp->value) free(temp->value);
                free(temp);
    }
}

void yyerror(const char *s) {
    printf("// ERRO SINTATICO: linha: %d: %s\n",line, s);
}

int main(void) {

    sym_table = (tabela_simbolos*) malloc(sizeof(tabela_simbolos));
    initSym(sym_table);

    printf("#include<stdio.h>\n\n");
    printf("int main() {\n\n");

    yyparse();

//    imprime_ts(sym_table);

    printf("\n    return 0;\n}\n");

    return 0;
}
