#include <stdio.h>
#include <string.h>
#include "btoc.h"
#include "y.tab.h"

int ntabs=0;
int ntabs_temp=0;

void identacao() {

    int i;

    for (i=0;i<=ntabs;i++){
        printf("    ");
    }
}

void verifica_init(nodeType *no, tabela_simbolos *ts){
    if (search(ts, no->id.value)){
        if ((ts->hasValue == 0) && (ts->type == 'v')){
                printf("\n    unsigned int %s;\n    ", no->id.value);
                ts->hasValue = 1;
        }else if ((ts->hasValue == 0) && (ts->type == 'f')){
                ts->hasValue = 1;
            }
     }
}

int gera_codigo(nodeType *p, tabela_simbolos *st) {

    if (!p) return 0;
    switch(p->type) {
    case typeNum:
        printf("%d", p->num.value);
        break;
    case typeId:        
        identacao();
        if ((st = search(st, p->id.value))){
            if ((st->type == 'f') && (st->hasValue == 1)){
                printf("%s();\n", p->id.value); 
            }else{
                verifica_init(p,st);
                printf("%s", p->id.value); 
            }
        }else
            printf("%s", p->id.value); 
        break;
    case typeOpr:
        switch(p->opr.oper) {
        case WHILE:
            identacao();
            printf("while (");
            ntabs_temp = ntabs; ntabs = -10;
            gera_codigo(p->opr.op[0],st);
            ntabs = ntabs_temp;
            printf(") \n");
            identacao();
            printf("{\n");
            ntabs++;
            gera_codigo(p->opr.op[1],st);
            ntabs--;
            identacao();
            printf("}\n");
            break;
        case IF:
            if (p->opr.nops > 2) {
                /* if else */
                identacao();
                printf("if (");
                ntabs_temp = ntabs; ntabs = -10;
                gera_codigo(p->opr.op[0],st);
                ntabs = ntabs_temp;
                printf(") \n");
                identacao();
                printf("{\n");
                ntabs++;
                gera_codigo(p->opr.op[1],st);
                ntabs--;
                identacao();
                printf("}\n");
                if (p->opr.nops > 3) {
                    gera_codigo(p->opr.op[2],st);
                } else {
                    identacao();
                    printf("else {\n");
                    ntabs++;
                    gera_codigo(p->opr.op[2],st);
                    ntabs--;
                    identacao();
                    printf("}\n");
                }
            } else {
                /* if */
                identacao();
                printf("if (");
                ntabs--;
                gera_codigo(p->opr.op[0],st);
                ntabs++;
                printf(")\n{\n");
                gera_codigo(p->opr.op[1],st);
                printf("}\n");
            }
            break;
        case ELIF:
            if (p->opr.nops > 2) {
                /* if else */
                identacao();
                printf("else if (");
                ntabs_temp = ntabs; ntabs = -10;
                gera_codigo(p->opr.op[0],st);
                ntabs = ntabs_temp;
                printf(") \n");
                identacao();
                printf("{\n");
                ntabs++;
                gera_codigo(p->opr.op[1],st);
                ntabs--;
                identacao();
                printf("}\n");
                if (p->opr.nops > 3) {
                    gera_codigo(p->opr.op[2],st);
                } else {
                    identacao();
                    printf("else {\n");
                    ntabs++;
                    gera_codigo(p->opr.op[2],st);
                    ntabs--;
                    identacao();
                    printf("}\n");
                }
            } else {
                /* if */
                identacao();
                printf("elif (");
                ntabs_temp = ntabs; ntabs = -10;
                gera_codigo(p->opr.op[0],st);
                ntabs = ntabs_temp;
                printf(")\n{\n");
                gera_codigo(p->opr.op[1],st);
                printf("}\n");
            }
            break;
        case ECHO:     
            identacao();
            if (p->opr.op[0]->id.type == 's'){
            printf("printf(");
            ntabs_temp = ntabs; ntabs = -10;
            gera_codigo(p->opr.op[0],st);
            ntabs = ntabs_temp;
            }
            else if (p->opr.op[0]->id.type == 'v'){
            printf("printf(\"%%d\\n\", ");
            ntabs_temp = ntabs; ntabs = -10;
            gera_codigo(p->opr.op[0],st);
            ntabs = ntabs_temp;
            }
            printf(");\n");
            break;
        case FUNCTION:
            printf("\n");
            identacao();
            printf("void ");
            ntabs_temp = ntabs; ntabs = -10;
            gera_codigo(p->opr.op[0],st);
            ntabs = ntabs_temp;
            printf("(){\n");
            ntabs++;
            gera_codigo(p->opr.op[1],st);
            ntabs--;
            identacao();
            printf("}\n\n");
            break;
        case READ:     
            identacao();
            verifica_init(p->opr.op[0],st);
            printf("scanf(\"%%d\",&");
            ntabs_temp = ntabs; ntabs = -10;
            gera_codigo(p->opr.op[0],st);
            ntabs = ntabs_temp;
            printf(");\n");
            break;
        case '=':  
            identacao();
            ntabs_temp = ntabs; ntabs = -10;
            gera_codigo(p->opr.op[0],st);
            printf(" = ");
            gera_codigo(p->opr.op[1],st);
            ntabs = ntabs_temp;
            printf(";\n");
            break;
        case FOR:
            identacao();
            verifica_init(p->opr.op[0],st);
            printf("for (");
            ntabs_temp = ntabs; ntabs = -10;
            if (p->opr.nops > 4) { 
                gera_codigo(p->opr.op[0],st);
                printf(" = ");
                gera_codigo(p->opr.op[1],st);
                printf(";");
                gera_codigo(p->opr.op[2],st);
                printf(";");
                switch(p->opr.op[4]->opr.oper) {
                    case INC_OP: printf("%s",p->opr.op[4]->opr.op[0]->id.value);  printf("++"); break;
                    case DEC_OP: printf("%s",p->opr.op[4]->opr.op[0]->id.value);  printf("--"); break;
                    default: gera_codigo(p->opr.op[4],st);
                }
                printf(")");
            }else{
                printf("%s= ", p->opr.op[0]->id.value);
                printf("%d;", p->opr.op[1]->num.value);
                printf("%s<=", p->opr.op[0]->id.value);
                printf("%d;", p->opr.op[2]->num.value);
                printf("%s++)", p->opr.op[0]->id.value);
            }
            ntabs = ntabs_temp;
            identacao();
            printf("{\n");
            ntabs++;
            gera_codigo(p->opr.op[3],st);
            ntabs--;
            identacao();
            printf("}\n");
            break;
        case UNTIL:
            identacao();
            printf("while (!(");
            ntabs_temp = ntabs; ntabs = -10;
            gera_codigo(p->opr.op[0],st);
            ntabs = ntabs_temp;
            printf(")) \n");
            identacao();
            printf("{\n");
            ntabs++;
            gera_codigo(p->opr.op[1],st);
            ntabs--;
            identacao();
            printf("}\n");
            break;
        case CASE:
            if (p->opr.nops >3) {   /*SWITCH*/
                identacao();
                printf("switch (%s) {\n", p->opr.op[0]->id.value);
                ntabs++;
                gera_codigo(p->opr.op[1],st);
                ntabs--;
                identacao();
                printf("}\n");
            }else if (p->opr.nops == 3) {  /*CASE STATEMENT*/
                gera_codigo(p->opr.op[0],st);
                gera_codigo(p->opr.op[1],st);
            }else if (p->opr.nops == 2) {  /*CASE CLAUSE*/
                identacao();
                if (p->opr.op[0]->opr.oper == '*'){
                    printf("default: \n");
                    ntabs++;
                    gera_codigo(p->opr.op[1],st);
                    identacao();
                    printf("break;\n");
                    ntabs--;
                }else if (p->opr.op[0]->opr.oper == '|'){
                    printf("case %d: case %d:\n", p->opr.op[0]->opr.op[0]->num.value, p->opr.op[0]->opr.op[1]->num.value);
                    ntabs++;
                    gera_codigo(p->opr.op[1],st);
                    identacao();
                    printf("break;\n");
                    ntabs--;
                }else{
                printf("case %d: \n", p->opr.op[0]->num.value);
                ntabs++;
                gera_codigo(p->opr.op[1],st);
                identacao();
                printf("break;\n");
                ntabs--;
                }
            }
            break;
        default:
            gera_codigo(p->opr.op[0],st);
            switch(p->opr.oper) {
            case '+':   printf(" + "); gera_codigo(p->opr.op[1],st); break;
            case '-':   printf(" - "); gera_codigo(p->opr.op[1],st); break;
            case '*':   printf(" * "); gera_codigo(p->opr.op[1],st); break;
            case '/':   printf(" / "); gera_codigo(p->opr.op[1],st); break;
            case '<':   printf(" < "); gera_codigo(p->opr.op[1],st); break;
            case '>':   printf(" > "); gera_codigo(p->opr.op[1],st); break;
            case INC_OP:   printf("++;\n"); break;
            case DEC_OP:   printf("--;\n"); break;
            case GE_OP:    printf(" >= "); gera_codigo(p->opr.op[1],st); break;
            case LE_OP:    printf(" <= "); gera_codigo(p->opr.op[1],st); break;
            case NE_OP:    printf(" != "); gera_codigo(p->opr.op[1],st); break;
            case EQ_OP:    printf(" == "); gera_codigo(p->opr.op[1],st); break;
            default:
                gera_codigo(p->opr.op[1],st);
            }
        }
    }

    return 0;
}

