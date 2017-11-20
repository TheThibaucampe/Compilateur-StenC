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
%token <string>IF
%token <string>ELSE
%token <string>WHILE
%token <string>FOR
%token <string>RETURN
%token <string>CONST
%token <string>DO
%token <string>STENCIL
%token <string>INT
%token <string>MAIN
%token <string>PRINTF
%token <string>PRINTI
%token <string>BOOL_OPERATOR


%type <codegen>expression
%type <codegen>code_line
%type <codegen>statement
%type <codegen>struct_control
%type <codegen>line


%left '-' '+'
%left '*' '/'

%start axiom

%%

axiom:
    line
    {
      quadsFinal = $1.code;
      printf("Match :-) !\n");
      return 0;
    }
;

line:
    statement line
    {
      $$.code = quadsConcat($1.code,$2.code,NULL);
      printf("line -> statement line\n");
    }

    | struct_control line
    {
      $$.code = quadsConcat($1.code,$2.code,NULL);
      printf("line -> struct_control line\n");
    }

	//function line


    | '\n'
      {
        printf("\\n\n");
      }	//TODO demander a bastoul

    | '\n' line
      {
        $$=$2;
        printf("\\n line\n");
      }
   ;

statement:
    code_line ';'
    {
      $$=$1;
      printf("statement -> code_line ;\n");
    }
  ;



code_line:
    expression
    {
      $$=$1;
      printf("code_line -> expression\n");
    }
	//TODO attribution
  ;

struct_control: 
   IF	{printf("IF\n");}
;

expression:
    expression '+' expression
    { 
      $$.result = newtemp(&tds);
      struct symbol* arg1 = lookup(tds,$1.result->nom);
      struct symbol* arg2 = lookup(tds,$3.result->nom);
      struct quads* newQuads = quadsGen("+",arg1,arg2,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression + expression\n");
    }

  | expression '-' expression
    { 
      $$.result = newtemp(&tds);
      struct symbol* arg1 = lookup(tds,$1.result->nom);
      struct symbol* arg2 = lookup(tds,$3.result->nom);
      struct quads* newQuads = quadsGen("-",arg1,arg2,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression - expression\n");
    }

  | expression '/' expression
    { 
      $$.result = newtemp(&tds);
      struct symbol* arg1 = lookup(tds,$1.result->nom);
      struct symbol* arg2 = lookup(tds,$3.result->nom);
      struct quads* newQuads = quadsGen("/",arg1,arg2,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression / expression\n");
    }


   | expression '*' expression
    { 
      $$.result = newtemp(&tds);
      struct symbol* arg1 = lookup(tds,$1.result->nom);
      struct symbol* arg2 = lookup(tds,$3.result->nom);
      struct quads* newQuads = quadsGen("*",arg1,arg2,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression * expression\n");
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
