%{

%}

%option yylineno
%x comment
%%
"/*"                     BEGIN(comment);
(?i:INT)                 {return(INT);}
(?i:STR)                 {return(STR);}
(?i:WHILE)               {return(WHILE);}
(?i:IF)                  {return(IF);}
(?i:ELSE)                {return(ELSE);}
(?i:START)               {return(START);}
(?i:STOP)                {return(STOP);}
(?i:WRITE)               {return(WRITE);}
(?i:READ)                {return(READ);}
==                       {return(EQUAL);}
"<"                      {return(INF);}
">"                      {return(SUP);}
"<="                     {return(INFEQ);}
">="                     {return(SUPEQ);}
-                        {return(SUB);}
[,;()=]                  {return(yytext[0]);}
\+                       {return(ADD);}
\*                       {return(MUL);}
\/                       {return(DIV);}
\"                       {return('\"');}
\{                       {return('{');}
\}                       {return('}');}
\!=                      {return(DIF);}
\%                       {return(MOD);}
[a-zA-Z]+                {yylval.vals=strdup(yytext);return(pal);}
[0-9]+                   {yylval.vali=atoi(yytext);return(num);}
.|\n                     { ; }

<comment>{
"*/"                     BEGIN(INITIAL);
[^*\n]+                  {;}  // eat comment in chunks
"*"                      {;}  // eat the lone star
\n                       {;}
}
%%

int yywrap(){
  return(1);
}
