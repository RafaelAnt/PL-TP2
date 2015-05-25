%{
#include <stdio.h>
#include <stdlib.h>
#include "hash.c"

#define _GNU_SOURCE
#define TRUE 1
#define FALSE 0

#define TYPE_INT 100
#define TYPE_STRING 101

#define SOMA 200
#define SUBTRACAO 201
#define MULTIPLICACAO 202
#define DIVISAO 203
#define DIV_INTEIRA 204

#define MAIOR 300
#define MENOR 301
#define IGUAL 302
#define DIFERENTE 303
#define MAIOR_OU_IGUAL 304
#define MENOR_OU_IGUAL 305

#define ERR_1 "Variable was already declared"
#define ERR_2 "Undeclared variable"
#define ERR_3 "Unexpected type (expected Integer)"
#define ERR_4 "Unexpected type (expected String)"

typedef struct termo{
  int tipo;
  int integer;
  char *string;
} Termo;

FILE *fp;

int nCiclos = 0, nIfs = 0, nOperacoes = 0, nAtribuicoes = 0, nDeclaracoes = 0, nComparacoes = 0;
int spVar=0, nlinhas = 1000, nCiclosJump=1;
int inicioCiclo [100], apontador=0;
int jumper[100], apontadorJumper=0;
HashTable h = NULL;
Variavel * v = NULL;


void printSumario();
void yyerror(char * e);
int getSize(char* text);
char* getOpComp (int a);
char* getOperador (int a);
%}

%union{int vali; char* vals; Termo valt;}
%token ADD SUB MUL DIV MOD
%token EQUAL SUP INF SUPEQ INFEQ DIF
%token INT STR WHILE IF ELSE START STOP
%token WRITE READ
%token <vals>pal <vali>num
%type <vali>Operador
%type <vali>OpComp
%type <valt>Termo
%%
Linguagem : ListaDeclaracoes START {fprintf(fp,"\n");} ListaExpressao STOP  {printSumario();}
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
          | Escrever ';'
          | Ler ';'
          ;

Ciclo : WHILE                        {inicioCiclo[apontador++]=nlinhas;}
        '('Comparacao ')'            {fprintf(fp,"%d JZ %d\n",nlinhas++,nCiclosJump);
                                     jumper[apontadorJumper++]=nCiclosJump;
                                     nCiclosJump++;}
        '{' ListaExpressao '}'       {fprintf(fp,"%d JUMP %d\n%d\n",nlinhas++,inicioCiclo[--apontador],jumper[--apontadorJumper]);}
      ;

IfElse : If                          {fprintf(fp,"%d JUMP %d\n%d\n",nlinhas++,nCiclosJump,jumper[--apontadorJumper]);
                                     jumper[apontadorJumper++]=nCiclosJump;
                                     nCiclosJump++;}
         ELSE '{' ListaExpressao '}' {fprintf(fp,"%d\n",jumper[--apontadorJumper]); nIfs++;}
       | If                          {fprintf(fp,"%d\n",jumper[--apontadorJumper]); nIfs++;}
       ;

If : IF '('Comparacao ')' {fprintf(fp,"%d JZ %d\n",nlinhas++,nCiclosJump);jumper[apontadorJumper++]=nCiclosJump; nCiclosJump++;}
    '{' ListaExpressao '}'
    ;


DeclaraInt : INT ListaVariaveisInt {nDeclaracoes++;}
           ;

ListaVariaveisInt : pal                            {if(hash_get(h,$1)!=NULL){yyerror(ERR_1);return;}hash_put(&h,$1,TYPE_INT,spVar);spVar++;fprintf(fp,"%d PUSHI 0\n",nlinhas++);}
                  | pal '=' num                    {if(hash_get(h,$1)!=NULL){yyerror(ERR_1);return;}hash_put(&h,$1,TYPE_INT,spVar);spVar++;fprintf(fp,"%d PUSHI %d\n",nlinhas++,$3);}
                  | pal                            {if(hash_get(h,$1)!=NULL){yyerror(ERR_1);return;}hash_put(&h,$1,TYPE_INT,spVar);spVar++;fprintf(fp,"%d PUSHI 0\n",nlinhas++);}                ',' ListaVariaveisInt
                  | pal '=' num                    {if(hash_get(h,$1)!=NULL){yyerror(ERR_1);return;}hash_put(&h,$1,TYPE_INT,spVar);spVar++;fprintf(fp,"%d PUSHI %d\n",nlinhas++,$3);}            ',' ListaVariaveisInt
                  ;

DeclaraStr : STR ListaVariaveisStr {nDeclaracoes++;}
           ;

ListaVariaveisStr : pal                            {if(hash_get(h,$1)!=NULL){yyerror(ERR_1);return;}hash_put(&h,$1,TYPE_STRING,spVar);spVar++;fprintf(fp,"%d PUSHS \"\"\n",nlinhas++);}
                  | pal '=' '\"'pal'\"'            {if(hash_get(h,$1)!=NULL){yyerror(ERR_1);return;}hash_put(&h,$1,TYPE_STRING,spVar);spVar++;fprintf(fp,"%d PUSHS \"%s\"\n",nlinhas++,$4);}
                  | pal                            {if(hash_get(h,$1)!=NULL){yyerror(ERR_1);return;}hash_put(&h,$1,TYPE_STRING,spVar);spVar++;fprintf(fp,"%d PUSHS \"\"\n",nlinhas++);}          ',' ListaVariaveisStr
                  | pal '=' '\"'pal'\"'            {if(hash_get(h,$1)!=NULL){yyerror(ERR_1);return;}hash_put(&h,$1,TYPE_STRING,spVar);spVar++;fprintf(fp,"%d PUSHS \"%s\"\n",nlinhas++,$4);}     ',' ListaVariaveisStr
                  ;

Operacao : Termo Operador Termo                    {if($1.tipo==TYPE_INT){fprintf(fp,"%d PUSHI %d\n",nlinhas++,$1.integer);}
                                                    else{v=hash_get(h,$1.string);
                                                         if(v==NULL){yyerror(ERR_2);return;}
                                                         if(v->tipo!=TYPE_INT){yyerror(ERR_3);return;}
                                                         fprintf(fp,"%d PUSHG %d\n",nlinhas++,v->pos);
                                                         }
                                                    if($3.tipo==TYPE_INT){fprintf(fp,"%d PUSHI %d\n",nlinhas++,$3.integer);}
                                                    else{v=hash_get(h,$3.string);
                                                        if(v==NULL){yyerror(ERR_2);return;}
                                                        if(v->tipo!=TYPE_INT){yyerror(ERR_3);return;}
                                                        fprintf(fp,"%d PUSHG %d\n",nlinhas++,v->pos);
                                                        }
                                                    fprintf(fp,"%d %s\n",nlinhas++,getOperador($2));
                                                    nOperacoes++;}
         | Termo Operador '('Operacao')'            {if($1.tipo==TYPE_INT){fprintf(fp,"%d PUSHI %d\n",nlinhas++,$1.integer);}
                                                     else{v=hash_get(h,$1.string);
                                                          if(v==NULL){yyerror(ERR_2);return;}
                                                          if(v->tipo!=TYPE_INT){yyerror(ERR_3);return;}
                                                          fprintf(fp,"%d PUSHG %d\n",nlinhas++,v->pos);
                                                          }
                                                     fprintf(fp,"%d %s\n",nlinhas++,getOperador($2));
                                                     nOperacoes++;}
         | '('Operacao')' Operador Termo             {if($5.tipo==TYPE_INT){fprintf(fp,"%d PUSHI %d\n",nlinhas++,$5.integer);}
                                                     else{v=hash_get(h,$5.string);
                                                         if(v==NULL){yyerror(ERR_2);return;}
                                                         if(v->tipo!=TYPE_INT){yyerror(ERR_3);return;}
                                                         fprintf(fp,"%d PUSHG %d\n",nlinhas++,v->pos);
                                                         }
                                                     fprintf(fp,"%d %s\n",nlinhas++,getOperador($4));
                                                     nOperacoes++;}
         | Operacao Operador Termo                   {if($3.tipo==TYPE_INT){fprintf(fp,"%d PUSHI %d\n",nlinhas++,$3.integer);}
                                                     else{v=hash_get(h,$3.string);
                                                         if(v==NULL){yyerror(ERR_2);return;}
                                                         if(v->tipo!=TYPE_INT){yyerror(ERR_3);return;}
                                                         fprintf(fp,"%d PUSHG %d\n",nlinhas++,v->pos);
                                                         }
                                                     fprintf(fp,"%d %s\n",nlinhas++,getOperador($2));
                                                     nOperacoes++;}
         ;

AtribuicaoInt : pal '=' num                        {v=hash_get(h,$1); if(v==NULL){yyerror(ERR_2);return;} if(v->tipo!=TYPE_INT){yyerror(ERR_4);return;}
                                                    fprintf(fp,"%d PUSHI %d\n",nlinhas++,$3); fprintf(fp,"%d STOREG %d\n",nlinhas++,v->pos); nAtribuicoes++;}
              | pal '=' Operacao                   {v=hash_get(h,$1); if(v==NULL){yyerror(ERR_2);return;} if(v->tipo!=TYPE_INT){yyerror(ERR_4);return;}
                                                    fprintf(fp,"%d STOREG %d\n",nlinhas++,v->pos); nAtribuicoes++;}
              ;

AtribuicaoStr : pal '=' '\"'pal'\"'                {v=hash_get(h,$1); if(v==NULL){yyerror(ERR_2);return;} if(v->tipo!=TYPE_STRING){yyerror(ERR_3);return;}
                                                    fprintf(fp,"%d PUSHS \"%s\"\n",nlinhas++,$4); fprintf(fp,"%d STOREG %d\n",nlinhas++,v->pos); nAtribuicoes++;}
               ;

Comparacao : Termo OpComp Termo                    {if($1.tipo==TYPE_INT){fprintf(fp,"%d PUSHI %d\n",nlinhas++,$1.integer);}
                                                    else{v=hash_get(h,$1.string);
                                                         if(v==NULL){yyerror(ERR_2);return;}
                                                         if(v->tipo!=TYPE_INT){yyerror(ERR_3);return;}
                                                         fprintf(fp,"%d PUSHG %d\n",nlinhas++,v->pos);
                                                         }
                                                    if($3.tipo==TYPE_INT){fprintf(fp,"%d PUSHI %d\n",nlinhas++,$3.integer);}
                                                    else{v=hash_get(h,$3.string);
                                                        if(v==NULL){yyerror(ERR_2);return;}
                                                        if(v->tipo!=TYPE_INT){yyerror(ERR_3);return;}
                                                        fprintf(fp,"%d PUSHG %d\n",nlinhas++,v->pos);
                                                        }
                                                    fprintf(fp,"%d %s\n",nlinhas++,getOpComp($2));
                                                    nComparacoes++;}
           ;

Escrever : WRITE '(' pal ')'                        {v=hash_get(h,$3);if(v==NULL){yyerror(ERR_2);return;} fprintf(fp,"%d PUSHG %d\n",nlinhas++,v->pos);
                                                    if(v->tipo==TYPE_INT){fprintf(fp,"%d WRITEI\n",nlinhas++);} if(v->tipo==TYPE_STRING){fprintf(fp,"%d WRITES\n",nlinhas++);}}
         ;

Ler : READ '(' pal ')'                              {v=hash_get(h,$3);if(v==NULL){yyerror(ERR_2);return;}
                                                    fprintf(fp,"%d READ\n",nlinhas++);fprintf(fp,"%d STOREG %d\n",nlinhas++,v->pos);}
    ;

OpComp : INF                                       {$$=MENOR;}
       | SUP                                       {$$=MAIOR;}
       | EQUAL                                     {$$=IGUAL;}
       | DIF                                       {$$=DIFERENTE;}
       | INFEQ                                     {$$=MENOR_OU_IGUAL;}
       | SUPEQ                                     {$$=MAIOR_OU_IGUAL;}
       ;

Operador : ADD                                     {$$=SOMA;}
         | SUB                                     {$$=SUBTRACAO;}
         | MUL                                     {$$=MULTIPLICACAO;}
         | DIV                                     {$$=DIVISAO;}
         | MOD                                     {$$=DIV_INTEIRA;}
         ;

Termo : pal                                        {$$.tipo=TYPE_STRING;$$.string=$1;}
      | num                                        {$$.tipo=TYPE_INT;$$.integer=$1;}
      ;


%%

#include "lex.yy.c"

void printSumario(){
  printf("*** Sucesso! ***\nSumário:\nDeclarações: %d\nAtribuições: %d\nComparações: %d\nOperações: %d\nCiclos: %d\nIf-Else: %d\n",nDeclaracoes,nAtribuicoes,nComparacoes,nOperacoes,nCiclos,nIfs);
}

void yyerror(char * e){
  printf("\n\n*** ERRO ***\n\nLinha %d.\nDescrição: %s\n\n************\n\n",yylineno,e);
  fprintf(fp,"\n\nERROR\n\n");
}

int getSize(char* text){
  int r=0;
  while(text!=NULL&&text[r]!='\0'){
    r++;
  }
  return r;
}

char* getOpComp (int a){
  switch(a){
    case(MENOR): return "INF";
    case(MAIOR): return "SUP";
    case(IGUAL): return "EQUAL";
    case(DIFERENTE): return "DIF";
    case(MENOR_OU_IGUAL): return "INFEQ";
    case(MAIOR_OU_IGUAL): return "SUPEQ";
  }
}

char* getOperador(int a){
  switch(a){
    case(SOMA): return "ADD";
    case(SUBTRACAO): return "SUB";
    case(MULTIPLICACAO): return "MUL";
    case(DIVISAO): return "DIV";
    case(DIV_INTEIRA): return "MOD";
  }
}

int main(){
  fp=fopen("output.txt","w");
  yyparse();
  fclose(fp);
  return 0;
}
