%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "tds.h"
  #include "quads.h"

  void yyerror(char*);
  int yylex();

  struct symbol* tds = NULL;
  struct quads* quadsFinal = NULL;
%}

%union{
	char* string;
	int value;

	struct{
		struct symbol* result;
		struct quads* code;
	} codegen;
}


%token <string>IDENTIFIER
%token <value>NUMBER
%token <string>OPERATOR
%type <codegen>expression
%type <codegen>statement
%type <codegen>ligne


%left '-'
%left OPERATOR

%start axiom

%%

axiom:
    ligne
    {
      quadsFinal = $1.code;
      printf("Match :-) !\n");
      return 0;
    }
;

ligne:
    '\n' ligne	{printf("retour chariot\n");}
    | statement ';' ligne	{printf("ligne -> statement ; ligne\n");}
    | '\n'	{printf("Epsilon ligne\n");}	//TODO demander a bastoul
  ;



statement:
    expression	{printf("statement -> expression\n");}
  ;

expression:
    expression OPERATOR expression
    { 
      $$.result = newtemp(&tds);
      struct symbol* arg1 = lookup(tds,$1.result->nom);
      struct symbol* arg2 = lookup(tds,$3.result->nom);
      struct quads* newQuads = quadsGen($2,arg1,arg2,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression %s expression\n",$2);
    }

  | '(' expression ')'
    {
      $$=$2;
      printf("expression -> ( expression )\n");
    }


  | '-' expression
    {
      $$.result = newtemp(&tds);
      struct symbol* arg1 = newtemp(&tds);
      arg1->valeur = 0;
      struct symbol* arg2 = lookup(tds,$2.result->nom);
      struct quads* newQuads= quadsGen("-",arg1,arg2,$$.result);


      $$.code = quadsConcat(NULL,$2.code,newQuads);
      printf("expression -> - expression\n");

    }

  | IDENTIFIER
    {
      $$.result = lookup(tds, $1);

      if($$.result == NULL)
      {
	$$.result = add(&tds,$1,false);
      }


      $$.code = NULL;
      printf("expression -> IDENTIFIER (%s)\n", $1);
    }

  | NUMBER
    {
      $$.result = newtemp(&tds);
      $$.result->valeur = $1;


      $$.code = NULL;
      printf("expression -> NUMBER (%d)\n", $1);
    }
  ;

%%

void yyerror (char *s) {
    fprintf(stderr, "[Yacc] error: %s\n", s);
}

int main() {
  printf("Enter an arithmetic expression:\n");
  yyparse();
  printf("-----------------\nSymbol table:\n");
  print(tds);
  printf("-----------------\nQuad list:\n");
  quadsPrint(quadsFinal);

  return 0;
}
