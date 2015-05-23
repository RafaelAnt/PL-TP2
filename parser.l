%{
  //[a-zA-Z][^a-zA-Z]        {yylval.valc=yytext[0]; printf("encontrei C: %c\n",yylval.valc); return(car);}
  //if(aux=='\0')return r;
%}

%option yylineno
%%
(?i:INT)                 {return(INT);}
(?i:CHAR)                {return(CHAR);}
(?i:WHILE)               {return(WHILE);}
(?i:IF)                  {return(IF);}
(?i:ELSE)                {return(ELSE);}
"\/\*"(.|\n)*"\*\/"      {;}                            //ignora comentários!
==                       {return(EQUALITY);}
[,;()=-><]               {return(yytext[0]);}
\+                       {return('+');}
\*                       {return('*');}
\/                       {return('/');}
\'                       {return('\'');}
\{                       {return('{');}
\}                       {return('}');}
\!                       {return('!');}
\%                       {return('%');}
[a-zA-Z]+                {if(getSize(yytext)==1){yylval.valc=yytext[0];return(car);
                         }else{yylval.vals=strdup(yytext);return(pal);}}
[0-9]+                   {yylval.vali=atoi(yytext);return(num);}
.|\n                     { ; }
%%

int yywrap(){
  return(1);
}

int getSize(char* text){
  char aux=text[0];
  int r=0;
  while(aux!=NULL){
    r++;
    aux=text[r];
  }
  return r;
}
