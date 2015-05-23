%{
#include <stdio.h>
#include <stdlib.h>
#include "hash.c"

#define _GNU_SOURCE
#define TYPE_INT 1
#define TYPE_STRING 2


FILE *fp;

int nCiclos = 0, nIfs = 0, nOperacoes = 0, nAtribuicoes = 0, nDeclaracoes = 0, nComparacoes = 0;
int spVar=0;
HashTable h = NULL;


void printSumario();
void yyerror(char * e);
int getSize(char* text);
%}

%union{int vali; char* vals;}
%token INT STR WHILE IF ELSE EQUALITY START STOP
%token <vals>pal <vali>num
%%
Linguagem : ListaDeclaracoes START ListaExpressao STOP  {printSumario();}
          ;

ListaDeclaracoes : Declaracao
                 | Declaracao ListaDeclaracoes
                 ;

Declaracao : DeclaraInt ';'
           | DeclaraStr ';'
           ;

ListaExpressao : Expressao
               | Expressao ListaExpressao
               ;



Expressao : Operacao ';'
          | AtribuicaoInt ';'
          | AtribuicaoStr ';'
          | Comparacao ';'
          | Ciclo
          | IfElse
          ;

Ciclo : WHILE '('Comparacao ')' '{' ListaExpressao '}' {nCiclos++;}

IfElse : IF '('Comparacao ')' '{' ListaExpressao '}' {nIfs++;}
       | IF '('Comparacao ')' '{' ListaExpressao '}' ELSE '{' ListaExpressao '}' {nIfs++;}

DeclaraInt : INT ListaVariaveisInt {nDeclaracoes++;}
           ;

ListaVariaveisInt : pal                          {if(hash_get(h,$1)!=NULL){yyerror("Variável já foi declarada.");return;}hash_put(&h,$1,TYPE_INT,spVar);spVar++;fprintf(fp,"PUSHI 0\n");}
                  | pal '=' num                  {if(hash_get(h,$1)!=NULL){yyerror("Variável já foi declarada.");return;}hash_put(&h,$1,TYPE_INT,spVar);spVar++;fprintf(fp,"PUSHI %d\n",$3);}
                  | pal                          {if(hash_get(h,$1)!=NULL){yyerror("Variável já foi declarada.");return;}hash_put(&h,$1,TYPE_INT,spVar);spVar++;fprintf(fp,"PUSHI 0\n");}                ',' ListaVariaveisInt
                  | pal '=' num                  {if(hash_get(h,$1)!=NULL){yyerror("Variável já foi declarada.");return;}hash_put(&h,$1,TYPE_INT,spVar);spVar++;fprintf(fp,"PUSHI %d\n",$3);}            ',' ListaVariaveisInt
                  ;

DeclaraStr : STR ListaVariaveisStr {nDeclaracoes++;}
           ;

ListaVariaveisStr : pal                          {if(hash_get(h,$1)!=NULL){yyerror("Variável já foi declarada.");return;}hash_put(&h,$1,TYPE_STRING,spVar);spVar++;fprintf(fp,"PUSHS \"\"\n");}
                  | pal '=' '\"'pal'\"'          {if(hash_get(h,$1)!=NULL){yyerror("Variável já foi declarada.");return;}hash_put(&h,$1,TYPE_STRING,spVar);spVar++;fprintf(fp,"PUSHS \"%s\"\n",$4);}
                  | pal                          {if(hash_get(h,$1)!=NULL){yyerror("Variável já foi declarada.");return;}hash_put(&h,$1,TYPE_STRING,spVar);spVar++;fprintf(fp,"PUSHS \"\"\n");}          ',' ListaVariaveisStr
                  | pal '=' '\"'pal'\"'          {if(hash_get(h,$1)!=NULL){yyerror("Variável já foi declarada.");return;}hash_put(&h,$1,TYPE_STRING,spVar);spVar++;fprintf(fp,"PUSHS \"%s\"\n",$4);}     ',' ListaVariaveisStr
                  ;

Operacao : Termo Operador Termo                         {nOperacoes++;}
         | Termo Operador '('Operacao')'
         | '('Operacao')' Operador Termo
         | Operacao Operador Termo
         ;

AtribuicaoInt : pal '=' num                        {nAtribuicoes++;}
              | pal '=' Operacao                   {nAtribuicoes++;}
              ;

AtribuicaoStr : pal '=' '\"'pal'\"'               {nAtribuicoes++;}
               ;

Comparacao : Termo OpComp Termo {nComparacoes++;}
           ;

OpComp : '<'
       | '>'
       | EQUALITY
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

Termo : pal
      | num
      ;


%%

#include "lex.yy.c"

void printSumario(){
  printf("*** Sucesso! ***\nSumário:\nDeclarações: %d\nAtribuições: %d\nComparações: %d\nOperações: %d\nCiclos: %d\nIf-Else: %d\n",nDeclaracoes,nAtribuicoes,nComparacoes,nOperacoes,nCiclos,nIfs);
}

void yyerror(char * e){
  printf("\n\n*** ERRO ***\n\nLinha %d.\nDescrição: %s\n\n************\n\n",yylineno,e);
  fclose(fp);
  fopen("output.txt","w");
}

int getSize(char* text){
  int r=0;
  while(text!=NULL&&text[r]!='\0'){
    r++;
  }
  return r;
}

int main(){
  fp=fopen("output.txt","w");
  yyparse();
  fclose(fp);
  return 0;
}
