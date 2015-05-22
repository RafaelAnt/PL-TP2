%{
#include <stdio.h>

#define _GNU_SOURCE
#define TypeINT 1
#define TypeChar 2
#define TypeString 3

int nComents = 0, nCiclos = 0, nIfs = 0, nOperacoes = 0, nAtribuicoes = 0, nDeclaracoes = 0, nComparacoes = 0;


void printSumario();
%}

%union{int vali; char valc; char* vals}
%token INT CHAR WHILE IF ELSE COMENT
%token <vals>pal <vali>num <valc>car
%%
Linguagem : Expressao                     {printSumario();}
          | Comentario                    {printSumario();}
          | Expressao Linguagem
          | Comentario Linguagem
          ;

ListaExpressao : Expressao
               | Expressao ListaExpressao
               ;

Comentario : COMENT                       {nComents++;}
           ;

Expressao : DeclaraInt ';'
          | DeclaraChar ';'
          | Operacao ';'
          | AtribuicaoInt ';'
          | AtribuicaoChar ';'
          | Comparacao ';'
          | Ciclo
          | IfElse
          ;

Ciclo : WHILE '('Comparacao {nComparacoes++;} ')' '{' ListaExpressao '}' {nCiclos++;}

IfElse : IF '('Comparacao ')' '{' ListaExpressao '}' {nIfs++;}
       | IF '('Comparacao ')' '{' ListaExpressao '}' ELSE '{' ListaExpressao '}' {nIfs++;}

DeclaraInt : INT ListaVariaveisInt {nDeclaracoes++;}
           ;

ListaVariaveisInt : Variavel
                  | Variavel '=' num
                  | Variavel ',' ListaVariaveisInt
                  | Variavel '=' num ',' ListaVariaveisInt
                  ;

DeclaraChar : CHAR ListaVariaveisChar {nDeclaracoes++;}
            ;

ListaVariaveisChar : Variavel
                   | Variavel '=' '\''car'\''
                   | Variavel ',' ListaVariaveisChar
                   | Variavel '=' '\''car'\'' ',' ListaVariaveisChar
                   ;

Operacao : Termo Operador Termo                         {nOperacoes++;}
         | Termo Operador '('Operacao')'
         | '('Operacao')' Operador Termo
         | Operacao Operador Termo
         ;

AtribuicaoInt : Variavel '=' num                        {nAtribuicoes++;}
              | Variavel '=' Operacao                   {nAtribuicoes++;}
              ;

AtribuicaoChar : Variavel '=' '\''car'\''               {nAtribuicoes++;}
               ;

Comparacao : Termo OpComp Termo {nComparacoes++;}
           ;

OpComp : '<'
       | '>'
       | '=''='
       | '!''='
       | '<''='
       | '>''='
       ;

Operador : '+'
         | '-'
         | '*'
         | '/'
         | '%'
         ;

Termo : Variavel
      | num
      ;

Variavel : pal
         | car
         ;

%%

#include "lex.yy.c"

/*
pal - palavra
num - numero
car - caratere
*/
void printSumario(){
  printf("*** Sucesso! ***\nSumário:\nDeclarações: %d\nAtribuições: %d\nComparações: %d\nOperações: %d\nComentários: %d\nCiclos: %d\nIf-Else: %d\n",nDeclaracoes,nAtribuicoes,nComparacoes,nOperacoes,nComents,nCiclos,nIfs);
}

void yyerror(char * e){
  printf("Erro sintático: %s\n\n",e);
}

int main(){
  yyparse();
  return 0;
}
