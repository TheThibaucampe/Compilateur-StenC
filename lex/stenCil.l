%{
  #include <stdlib.h>
  #include <string.h>
  #include "y.tab.h"
  #include <string.h>
%}

KEYWORD "int"|"if"|"else"|"while"|"for"|"main"|"printf"|"printi"|"stencil"|"return"|"const"|"do"
IDENTIFIER [a-zA-Z][0-9a-zA-Z_]*
/*Revoir constant pour les notations hexa, octa, binaire*/
NUMBER ([0-9]+)|([0-9]+(\.[0-9]*)?([eE][+-]?[0-9]+)?[alLfF]?)
STRING \"[^\"]*\"
OPERATOR "+"|"-"|"*"|"/"|"$"|"="|"<"|">"|"<="|">="|"=="|"!="|"&&"
UNARY_POSTFIX_OPERATOR "++" | "--"
PUNCTUATION "["|"]"|"("|")"|"{"|"}"|"||"|"#"|","|";"
PREPROC (\<[a-zA-Z][0-9a-zA-Z_]+\.[a-zA-Z]+\>)|(\"[a-zA-Z][0-9a-zA-Z_]+\.[a-zA-Z]+\")
COMMENT ("//".*\n)|(\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/)
SPACES \n|\t


%%

{COMMENT}		{return yytext[0];}
{SPACES}      		{return yytext[0];}
{IDENTIFIER}		{yylval.string = strdup(yytext);
			return IDENTIFIER;}
{NUMBER}		{yylval.value = atoi(yytext);
			return NUMBER;}
{STRING}		{yylval.string = strdup(yytext);}
{OPERATOR}		{yylval.string = strdup(yytext);
			return OPERATOR;}
{PUNCTUATION}		{return yytext[0];}

.            	{ printf("[Lex] Unknown lexical unit: %s\n", yytext); }

%%
