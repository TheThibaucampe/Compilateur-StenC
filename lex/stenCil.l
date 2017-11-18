%{
  #include <stdlib.h>
  #include <string.h>
  #include "y.tab.h"
  #include <string.h>
%}

KEYWORD "int"|"if"|"else"|"while"|"for"|"main"|"printf"|"printi"|"stencil"|"return"|"const"|"do"
IDENTIFIER [a-zA-Z][0-9a-zA-Z_]*
/*Revoir constant pour les notations hexa, octa, binaire*/
CONSTANT ([0-9]+)|([0-9]+(\.[0-9]*)?([eE][+-]?[0-9]+)?[alLfF]?)
STRING \"[^\"]*\"
OPERATOR "+"|"-"|"*"|"/"|"++"|"--"|"$"|"="|"<"|">"|"<="|">="|"=="|"!="|"&&"
PUNCTUATION "["|"]"|"("|")"|"{"|"}"|"||"|"#"|","|";"
PREPROC (\<[a-zA-Z][0-9a-zA-Z_]+\.[a-zA-Z]+\>)|(\"[a-zA-Z][0-9a-zA-Z_]+\.[a-zA-Z]+\")
COMMENT ("//"[^"\n"]*"\n")|(/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/)
SPACES "\n"|"\t"


%%

{COMMENT}		{return yytext;}
{SPACES}      	{return yytext;}
{KEYWORD}		{}
{IDENTIFIER}	{}
{CONSTANT}		{}
{STRING}		{}
{OPERATOR}		{}
{PUNCTUATION}	{}
{PREPROC}		{}

.            	{ printf("[Lex] Unknown lexical unit: %s\n", yytext); }

%%
