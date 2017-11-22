%{
  #include <stdlib.h>
  #include <string.h>
  #include "y.tab.h"
  #include <string.h>
%}

IDENTIFIER [a-zA-Z][0-9a-zA-Z_]*
NUMBER (("0"|"0x"|"0b")?[0-9]+)|([0-9]+(\.[0-9]*)?([eE][+-]?[0-9]+)?[alLfF]?)
OPERATOR "+"|"-"|"*"|"/"|"="
BOOL_OPERATOR "<"|">"|"<="|">="|"=="|"!="|"&&"|"!"|"||"
UNARY_POSTFIX_OPERATOR "++"|"--"
PUNCTUATION "["|"]"|"("|")"|"{"|"}"|"#"|","|";"
STRING \"[^\"]*\"
PREPROC ("#define "[a-zA-Z][0-9a-zA-Z_]*" "[0-9a-zA-Z_]+)|("#include "(\<[a-zA-Z][0-9a-zA-Z_]+\.[a-zA-Z]+\>)|(\"[a-zA-Z][0-9a-zA-Z_]+\.[a-zA-Z]+\"))
COMMENT ("//".*\n)|(\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/)
SPACES \n|\t|" "


%%

{COMMENT}			{}
{SPACES}      			{}
"if"				{return IF;}	
"else"				{return ELSE;}
"while"				{return WHILE;}
"for"				{return FOR;}
"return"			{return RETURN;}
"const"				{return CONST;}
"stencil"			{return STENCIL;}
"int"				{return INT;}
"main"				{return MAIN;}
"printf"			{return PRINTF;}
"printi"			{return PRINTI;}
{BOOL_OPERATOR}			{yylval.string = strdup(yytext);}
{OPERATOR}			{return yytext[0];}
{UNARY_POSTFIX_OPERATOR}	{yylval.string = strdup(yytext);}
{PUNCTUATION}			{return yytext[0];}

{IDENTIFIER}			{yylval.string = strdup(yytext); return IDENTIFIER;}
{NUMBER}			{yylval.value = atoi(yytext); return NUMBER;}
{STRING}			{yylval.string = strdup(yytext);}

.           		 	{ printf("[Lex] Unknown lexical unit: %s\n", yytext); }

%%
