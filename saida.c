#include<stdio.h>

int main() {

    
    unsigned int x;
    scanf("%d",&x);
    
    unsigned int y;
    y = 5;
    
    unsigned int i;
    for (i = 0;i <= 10;i++)    {
        printf("estou no for");
    }

    void hello(){
        printf("Funcao Hello");
        y = x / 2;
        printf("%d\n", y);
    }

    
    unsigned int COUNTER;
    COUNTER = 20;
    while (!(COUNTER < 10)) 
    {
        printf("%d\n", COUNTER);
        COUNTER--;
    }
    while (x <= 10) 
    {
        if (x <= 2) 
        {
            y = y - 1;
            printf("entrou no if");
        }
        else if (x >= 5) 
        {
            printf("entrou no elif");
            y = y - 1;
        }
        else {
            printf("entrou no else");
        }
        x++;
    }
    hello();
    printf("Switch case, (1) case simples, (2) case | case, qualquer outro numero, DEFAULT ");
    
    unsigned int DISTR;
    scanf("%d",&DISTR);
    switch (DISTR) {
        case 1: 
            printf("Case Simples.");
            break;
        case 2: case 3:
            printf("case | case)");
            break;
        default: 
            printf("Default.");
            break;
    }

    return 0;
}
