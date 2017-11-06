#!/bin/bash

echo -e "\e[34;44mVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV\e[0m"

lex lexico.l
if ! [ $? -eq 0 ] ; then
    echo -e "\e[1;31m(EE) Erro de compilacao do Flex \e[0m"
    exit 1
fi

echo -e "\e[32m===== Lex - Compilado =====\e[0m"

yacc sintatico.y -d -y --report=state
if ! [ $? -eq 0 ] ; then
    echo -e "\e[1;31m(EE) Erro de compilacao do Bison \e[0m"
    exit 1
fi

echo -e "\e[32m===== Yacc - Compilado =====\e[0m"

gcc -c y.tab.c lex.yy.c
if ! [ $? -eq 0 ] ; then
    echo -e "\e[1;31m(EE) Erro de compilacao do GCC \e[0m"
    exit 1
fi

gcc y.tab.o lex.yy.o btoc.c -o btoc -Wall -Wextra -Wmissing-prototypes -Wstrict-prototypes
if ! [ $? -eq 0 ] ; then
    echo -e "\e[1;31m(EE) Erro de compilacao do GCC \e[0m"
    exit 1
fi

echo -e "\e[32m===== GCC - Compilado =====\e[0m"

if [[ -e btoc ]] ; then
    echo && echo -e "\e[34m===== Execucao com entrada sem erro =====\e[0m" 
    echo -e         "\e[34m-----------------------------------------\e[0m"
	./btoc < entrada.sh 
	./btoc < entrada.sh > saida.c 
    echo && echo -e "\e[34m-----------------------------------------\e[0m"

    echo && echo -e "\e[34m===== Execucao com entrada com erro =====\e[0m" 
    echo -e         "\e[34m-----------------------------------------\e[0m"
	./btoc < entrada-com-erros.sh 
	./btoc < entrada-com-erros.sh > saida-com-erros.c 
    echo && echo -e "\e[34m-----------------------------------------\e[0m"
fi


echo -e "\e[37m===== Remover arquivos intermediarios? [s/n]=====\e[0m"
read opc

if [ $opc == 's' ]; then
    rm btoc lex.yy.* y.tab.*
    echo -e "\e[37m Arquivos removidos \e[0m"
fi

