%{
#include <stdlib.h>
#include <string.h>
#include "btoc.h"
#include "y.tab.h"

extern YYSTYPE yyval;
int line=0;
%}

digits      [0-9]
ltr         [a-zA-Z]
alphanum    [a-zA-Z0-9]

%%
 /*Cabecalho e comentarios*/
#[^\n]*         line++;

 /*Argumentos e Variaveis*/
"$"{alphanum}+  {yylval.sValue = strdup(yytext+1); return(VAR);}
{digits}+       {yylval.iValue = atoi(yytext); return(INT);}

 /*Strings*/
{ltr}?\"(\\.|[^\\"])*\"   {yylval.sValue = strdup(yytext); return(STRING);}

 /*Funcoes*/
"case"		return(CASE);
"do"		return(DO);
"done"		return(DONE);
"echo"      return(ECHO);
"else"		return(ELSE);
"elif"		return(ELIF);
"esac"		return(ESAC);
"fi"        return(FI);
"for"       return(FOR);
"function"  return(FUNCTION);
"if"		return(IF);
"in"        return(IN);
"read"      return(READ);
"then"		return(THEN);
"until"     return(UNTIL);
"while"     return(WHILE);

[-(){}<>=+*/;&|]    return(*yytext);
"["         return(*yytext);
"]"         return(*yytext);
".."        return(LOOPFOR);
";;"        return(SEMI_SEMI);

"++"		return(INC_OP);
"--"		return(DEC_OP);
"&&"		return(AND_OP);
"||"		return(OR_OP);
"<="		return(LE_OP);
"-le"		return(LE_OP);
"-lt"		return(LT_OP);
">="		return(GE_OP);
"-ge"		return(GE_OP);
"-gt"		return(GT_OP);
"=="		return(EQ_OP);
"-eq"		return(EQ_OP);
"!="		return(NE_OP);
"-ne"		return(NE_OP);

{ltr}+          {yylval.sValue = strdup(yytext); return(VAR);}

[\n]            {line++; return(*yytext);}

[ \t\v\f]+	{ /* consome espaco em branco */ }

.               {printf("\n// ERRO LEXICO: Letra ou simbolo desconhecido:%s na linha %d\n",yytext, line);}
%%
int yywrap(void) {
    return 1;
}

