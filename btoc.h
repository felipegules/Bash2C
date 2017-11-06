typedef enum { typeNum, typeId, typeOpr } nodeEnum;

/* inteiros */
typedef struct {
    int value;                  /* valor do inteiro */
} numNodeType;

/* identificadores */
typedef struct {
        char type;
        char *value;            /* Adiciona no vetor de simbolos */
} idNodeType;

/* operadores */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag **op;	/* operands */
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* tipo do noh */

    union {
        numNodeType num;        /* constants */
        idNodeType id;          /* identificadores */
        oprNodeType opr;        /* operators */
    };
} nodeType;

struct tabela_simbolos;
typedef struct tabela_simbolos {
        int type;
        char* value;               /* valor da variavel ou string */
        int hasValue;
        struct tabela_simbolos* next;
} tabela_simbolos;

extern int line;
extern int lineno;

/* Estruturas da arvore sintatica */
nodeType *opr(int oper, int nops, ...);
nodeType *id(char type, char *s);
nodeType *num(int valor);
tabela_simbolos *add(char *valor, char tipo);
tabela_simbolos *search(tabela_simbolos* st, char *name);
void imprime_ts(tabela_simbolos *st);
void initSym(tabela_simbolos* ptrSym);
void apaga_ts(void);
void freeNode(nodeType *p);
int constroi_arvore(nodeType *p);
int yylex(void);
void yyerror(const char *s);

void identacao(void);
void verifica_init(nodeType *no, tabela_simbolos *ts);
int gera_codigo(nodeType *p, tabela_simbolos *st);

