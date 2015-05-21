# PL-TP2
Repositório para ficheiros de trabalho prático 2 da disciplina de Processamento de Linguagens.

Comandos:

flex parser.l
yacc -d -v analise.y 
gcc -o tp2 y.tab.c

Ou:

flex parser.l | yacc -d -v analise.y | gcc -o tp2 y.tab.c


Para testar:

./tp2 < teste.txt
