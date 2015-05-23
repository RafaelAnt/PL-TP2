%{

%}

%option yylineno
%%
(?i:INT)                 {return(INT);}
(?i:STR)                 {return(STR);}
(?i:WHILE)               {return(WHILE);}
(?i:IF)                  {return(IF);}
(?i:ELSE)                {return(ELSE);}
(?i:START)               {return(START);}
(?i:STOP)                {return(STOP);}
"\/\*"(.|\n)*"\*\/"      {;}                            //ignora comentários!
==                       {return(EQUALITY);}
[,;()=-><]               {return(yytext[0]);}
\+                       {return('+');}
\*                       {return('*');}
\/                       {return('/');}
\"                       {return('\"');}
\{                       {return('{');}
\}                       {return('}');}
\!                       {return('!');}
\%                       {return('%');}
[a-zA-Z]+                {yylval.vals=strdup(yytext);return(pal);}
[0-9]+                   {yylval.vali=atoi(yytext);return(num);}
.|\n                     { ; }
%%

int yywrap(){
  return(1);
}
