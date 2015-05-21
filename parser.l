%{

%}


%%
(?i:INT) 	        {return(INT);}
(?i:CHAR) 	      {return(CHAR);}
(?i:WHILE) 	      {return(WHILE);}
(?i:IF) 	        {return(IF);}
(?i:ELSE) 	      {return(ELSE);}
(\/\*).*(\*\/)    {return(COMENT);}
[,;()=-><]        {return(yytext[0]);}
\+                {return('+');}
\*                {return('*');}
\/                {return('/');}
\'                {return('\'');}
\{                {return('{');}
\}                {return('}');}
\!                {return('!');}
[a-zA-Z] 	        {return(car);}
[a-zA-Z]+   	    {return(pal);}
[0-9]+      	    {return(num);}
.|\n       	      { ; }
%%

int yywrap()
{ return(1); }
