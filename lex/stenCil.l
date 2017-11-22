%{
  #include <stdlib.h>
  #include <string.h>
  #include "y.tab.h"
  #include <string.h>
%}

KEYWORD "if"|"else"|"while"|"for"|"return"|"const"|"do"
TYPE "stencil"|"int"
FUNCTION "main"|"printf"|"printi"
IDENTIFIER [a-zA-Z][0-9a-zA-Z_]*
NUMBER (("0"|"0x"|"0b")?[0-9]+)|([0-9]+(\.[0-9]*)?([eE][+-]?[0-9]+)?[alLfF]?)
STRING \"[^\"]*\"
OPERATOR "+"|"-"|"*"|"/"|"$"|"="
BOOL_OPERATOR "<"|">"|"<="|">="|"=="|"!="|"&&"
UNARY_POSTFIX_OPERATOR "++" | "--"
PUNCTUATION "["|"]"|"("|")"|"{"|"}"|"||"|"#"|","|";"
PREPROC ("#define "[a-zA-Z][0-9a-zA-Z_]*" "[0-9a-zA-Z_]+)|("#include "(\<[a-zA-Z][0-9a-zA-Z_]+\.[a-zA-Z]+\>)|(\"[a-zA-Z][0-9a-zA-Z_]+\.[a-zA-Z]+\"))
COMMENT ("//".*\n)|(\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/)
SPACES \n|\t|" "


%%

{COMMENT}			{}
{SPACES}      		{}
{KEYWORD}			{	if (strcmp("if", yytext) == 0)
						{
							yylval.string = strdup(yytext); return IF;
						} else
						if (strcmp("else", yytext) == 0)
						{
							yylval.string = strdup(yytext); return ELSE;
						} else
						if (strcmp("while", yytext) == 0)
						{
							yylval.string = strdup(yytext); return WHILE;
						} else
						if (strcmp("for", yytext) == 0)
						{
							yylval.string = strdup(yytext); return FOR;
						} else
						if (strcmp("return", yytext) == 0)
						{
							yylval.string = strdup(yytext); return RETURN;
						} else
						if (strcmp("const", yytext) == 0)
						{
							yylval.string = strdup(yytext); return CONST;
						} else
						if (strcmp("do", yytext) == 0)
						{
							yylval.string = strdup(yytext); return DO;
						} 
					}
{TYPE}				{	if (strcmp("stencil", yytext) == 0)
						{
							return STENCIL;
						} else
						if (strcmp("int", yytext) == 0)
						{
							return INT;
						}
					}
{FUNCTION}				{	if (strcmp("main", yytext) == 0)
						{
							yylval.string = strdup(yytext); return MAIN;
						} else
						if (strcmp("printf", yytext) == 0)
						{
							yylval.string = strdup(yytext); return PRINTF;
						} else
						if (strcmp("print", yytext) == 0)
						{
							yylval.string = strdup(yytext); return PRINTI;
						}
					}

{IDENTIFIER}		{yylval.string = strdup(yytext);
			return IDENTIFIER;}
{NUMBER}		{yylval.value = atoi(yytext);
			return NUMBER;}
{STRING}		{yylval.string = strdup(yytext);}
{OPERATOR}		{return yytext[0];}
{BOOL_OPERATOR}		{yylval.string = strdup(yytext);
			return BOOL_OPERATOR;}
{PUNCTUATION}		{return yytext[0];}


.            	{ printf("[Lex] Unknown lexical unit: %s\n", yytext); }

%%
