%{
  #include <stdlib.h>
  #include <string.h>
  #include "y.tab.h"
  #include <string.h>
%}

IDENTIFIER [a-zA-Z][0-9a-zA-Z_]*
NUMBER (("0"|"0x"|"0b")?[0-9]+)|([0-9]+(\.[0-9]*)?([eE][+-]?[0-9]+)?[alLfF]?)
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
"++"			{return INCR;}
"--"			{return DECR;}
"+"				{return PLUS;}
"-"				{return MINUS;}
"*"				{return MUL;}
"/"				{return DIV;}
"$"				{return STENCIL_OP;}
"="				{return ASSIGN;}
"!"				{return NOT;}
"<"				{return STRICT_LESS;}
">"				{return STRICT_MORE;}
"<="			{return LESS;}
">="			{return MORE;}
"=="			{return EQUAL;}
"!="			{return NOTEQUAL;}
"&&"			{return AND;}
"||"			{return OR;}
"["				{return CROCHET_G;}
"]"				{return CROCHET_D;}
"("				{return PARENTHESE_G;}
")"				{return PARENTHESE_D;}
"{"				{return ACCOLADE_G;}
"}"				{return ACCOLADE_D;}
"#"				{return DIEZE;}
","				{return VIRGULE;}	
";"				{return POINT_VIRGULE;}

{IDENTIFIER}	{yylval.string = strdup(yytext); return IDENTIFIER;}
{NUMBER}		{yylval.value = atoi(yytext); return NUMBER;}
{STRING}		{yylval.string = strdup(yytext);}

.            	{ printf("[Lex] Unknown lexical unit: %s\n", yytext); }

%%
