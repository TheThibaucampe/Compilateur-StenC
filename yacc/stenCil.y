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
%token IF
%token ELSE
%token WHILE
%token FOR
%token RETURN
%token CONST
%token DO
%token STENCIL
%token INT
%token MAIN
%token PRINTF
%token PRINTI
%token BOOL_OPERATOR


%type <codegen>expression
%type <codegen>code_line
%type <codegen>statement
%type <codegen>struct_control
%type <codegen>line
%type <codegen>attribution
%type <codegen>declaration
%type <codegen>var
%type <codegen>list_var


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
    line statement
    {
      $$.code = quadsConcat($1.code,$2.code,NULL);
      //XXX Code?
      printf("line -> statement line\n");
    }

    | statement
    {
      $$ = $1;
      printf("line -> statement\n");
    }

   ;

statement:
    code_line ';'
    {
      $$=$1;
      printf("statement -> code_line ;\n");
    }

    | struct_control
    {
      $$ = $1;
      printf("line -> struct_control line\n");
    }
	//function

  ;



code_line:
    attribution
    {
      $$=$1;
      printf("code_ligne -> attribution\n");
    }

    | declaration
    {
       $$ = $1;
       printf("code_ligne -> declaration\n");
    }
  ;

struct_control: 
   IF	{printf("IF\n");}	//TODO
;


declaration:
   INT list_var
   {
     $$=$2;
     printf("declaration -> INT list_var\n");
   }
	//pour stencil
   ;


list_var:
   var ',' list_var
   {
     $$.code = quadsConcat($1.code,$3.code,NULL);
     //XXX result?
     printf("list_var -> list_var var\n");
   }

   | var
   {
     $$=$1;
     printf("list_var -> var\n");
   }

  ;

var:
   IDENTIFIER
   {
     struct symbol* tmp = lookup(tds,$1);

     if(tmp != NULL)
     {
       printf("Redéclaration de %s\n",$1);
       return -1;
     }


     //XXX stocker type?
     $$.result = add(&tds, $1, false);
     printf("var ->ID\n");
     //XXX code
   }

   | IDENTIFIER '=' expression
   {
     struct symbol* tmp = lookup(tds,$1);

     if(tmp != NULL)
     {
       printf("Redéclaration de %s\n",$1);
       return -1;
     }


     $$.result = add(&tds,$1,false);
     $$.code = $3.code;		//XXX code d'attribution

   }



attribution:	//utilisable que pour les var de type int
   IDENTIFIER '=' expression
   {
     struct symbol* tmp = lookup(tds,$1);

     if(tmp == NULL)
     {
       printf("première utilisation de %s sans déclaration\n",$1);
       return -1;
     }

     if(tmp->constante == true)
     {
       printf("Tentative de modification d'une constante\n");
       return -1;
     }

     $$.result = add(&tds,$1,false);	//XXX opti: soit add ou renomage
     $$.code = $3.code;		//XXX code d'attribution
     printf("attribution -> ID = expression\n");
   }
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
        printf("utilisation de %s sans declaration\n",$1);
        return -1;
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
