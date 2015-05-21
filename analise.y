%{

%}

%token INT CHAR WHILE IF ELSE COMENT
%token pal num car
%%
Linguagem : ListaExpressao
          | Comentario
          | Expressao Linguagem
          | Comentario Linguagem
          ;                                           {printf("Sucesso!\n");}

ListaExpressao : Expressao
               | Expressao ListaExpressao
               ;

Comentario : '/''*' COMENT '*''/'
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

Ciclo : WHILE '('Comparacao')' '{' ListaExpressao '}'

IfElse : IF '('Comparacao')' '{' ListaExpressao '}'
       | IF '('Comparacao')' '{' ListaExpressao '}' ELSE '{' ListaExpressao '}'

DeclaraInt : INT ListaVariaveisInt
           ;

ListaVariaveisInt : Variavel
                  | Variavel '=' num
                  | Variavel ',' ListaVariaveisInt
                  | Variavel '=' num ',' ListaVariaveisInt
                  ;

DeclaraChar : CHAR ListaVariaveisChar
            ;

ListaVariaveisChar : Variavel
                   | Variavel '=' '\''car'\''
                   | Variavel ',' ListaVariaveisChar
                   | Variavel '=' '\''car'\'' ',' ListaVariaveisChar
                   ;

Operacao : Termo Operador Termo
         | Termo Operador '('Operacao')'
         | '('Operacao')' Operador Termo
         | Operacao Operador Termo
         ;

AtribuicaoInt : Variavel '=' num
              | Variavel '=' Operacao
              ;

AtribuicaoChar : Variavel '=' '\''car'\''
               ;

Comparacao : Termo OpComp Termo
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

void yyerror(char * e){
  printf("Erro sintático: %s\n\n",e);
}

int main(){
  yyparse();
  return 0;
}
