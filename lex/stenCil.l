%{
  #include "binaryconvert.h"
  #include "y.tab.h"
  #include <string.h>

%}

IDENTIFIER [a-zA-Z][0-9a-zA-Z_]*
NUMBER ("-")?("0"|([1-9][0-9]*)|("0b"[0-1]+)|("0"[0-7]+)|("0x"[0-9A-F]+))
OPERATOR "+"|"-"|"*"|"/"|"="|"$"
PUNCTUATION "["|"]"|"("|")"|"{"|"}"|"#"|","|";"
STRING \"[^\"]*\"
PREPROC ("#define "[a-zA-Z][0-9a-zA-Z_]*" "[0-9a-zA-Z_]+)|("#include "(\<[a-zA-Z][0-9a-zA-Z_]+\.[a-zA-Z]+\>)|(\"[a-zA-Z][0-9a-zA-Z_]+\.[a-zA-Z]+\"))
COMMENT ("//".*\n)|(\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/)
SPACES \n|\t|" "


%%

{COMMENT}		{}
{SPACES}      	{}
"if"			{return IF;}	
"else"			{return ELSE;}
"while"			{return WHILE;}
"for"			{return FOR;}
"return"		{return RETURN;}
"const"			{return CONST;}
"stencil"		{return STENCIL;}
"int"			{return INT;}
"main"			{return MAIN;}
"printf"		{return PRINTF;}
"printi"		{return PRINTI;}
"=="			{return EQUAL;}
"<="			{return LOWEREQ;}
">="			{return GREATEREQ;}
"!="			{return NOTEQUAL;}
"&&"			{return AND;}
"!"|">"|"<"		{return yytext[0];}
"||"			{return OR;}
"++"			{return INCR;}
"--"			{return DECR;}
			
{NUMBER}		{yylval.value =  convert(yytext); return NUMBER;}
{OPERATOR}		{return yytext[0];}
"]"{SPACES}*"["	{return DIM_SEPARATOR;}
{PUNCTUATION}	{return yytext[0];}

{IDENTIFIER}	{yylval.string = strdup(yytext); return IDENTIFIER;}
{STRING}		{yylval.string = strdup(yytext); return STRING;}

.           	{ printf("[Lex] Unknown lexical unit: %s\n", yytext); }

%%
