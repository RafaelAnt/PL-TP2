%{

%}


%%
(?i:INT)                 {return(INT);}
(?i:CHAR)                {return(CHAR);}
(?i:WHILE)               {return(WHILE);}
(?i:IF)                  {return(IF);}
(?i:ELSE)                {return(ELSE);}
"\/\*"(.|\n)*"\*\/"      {;}                            //ignora comentários!
[,;()=-><]               {return(yytext[0]);}
\+                       {return('+');}
\*                       {return('*');}
\/                       {return('/');}
\'                       {return('\'');}
\{                       {return('{');}
\}                       {return('}');}
\!                       {return('!');}
\%                       {return('%');}
[a-zA-Z]                 {yylval.valc=yytext[0];return(car);}
[a-zA-Z]+                {yylval.vals=strdup(yytext); return(pal);}
[0-9]+                   {yylval.vali=atoi(yytext); return(num);}
.|\n                     { ; }
%%

int yywrap(){
  return(1);
}
