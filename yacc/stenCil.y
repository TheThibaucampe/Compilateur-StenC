%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "tds.h"
  #include "quads.h"
  #include "quadlist.h"

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
    struct quadlist* truelist;
    struct quadlist* falselist;
	} codegen;
}


%token <string>IDENTIFIER
%token <value>NUMBER
%token <value>TRUE
%token <value>FALSE
%token IF
%token ELSE
%token WHILE
%token FOR
%token RETURN
%token CONST
%token STENCIL
%token INT
%token MAIN
%token PRINTF
%token PRINTI
%token INCR
%token DECR
%token MINUS
%token MUL
%token DIV
%token STENCIL_OP
%token ASSIGN
%token NOT
%token STRICT_LESS
%token STRICT_MORE
%token LESS
%token MORE
%token EQUAL
%token NOTEQUAL
%token AND
%token OR
%token CROCHET_G
%token CROCHET_D
%token PARENTHESE_G
%token PARENTHESE_D
%token ACCOLADE_G
%token ACCOLADE_D
%token DIEZE
%token VIRGULE
%token POINT_VIRGULE


%type <codegen>condition
%type <codegen>expression
%type <codegen>code_line
%type <codegen>statement
%type <codegen>line
%type <codegen>attribution
%type <codegen>declaration
%type <codegen>var
%type <codegen>list_var


%left MINUS PLUS
%left MUL DIV

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
      printf("line -> statement list line\n");
    }

    | statement
    {
      $$ = $1;
      printf("line -> statement\n");
    }
   ;


statement:
    code_line POINT_VIRGULE
    {
      $$=$1;
      printf("statement -> code_line ;\n");
    }

    //Issu du TP3
    | IDENTIFIER ASSIGN expression
    {
      //TODO
    }

    | WHILE condition ACCOLADE_G line ACCOLADE_D
    {
      //Issu du cours de Compil
      complete($2.truelist, $4.code);
      //find lasts quads
      struct quads* ptr1 = $2.code; struct quads* ptr2 = $4.code;
      while (ptr1->suivant != NULL && ptr2->suivant != NULL) //Oui, je sais, c'est une optimisation
      {
        ptr1 = ptr1->suivant; ptr2 = ptr2->suivant;
      }
      if (ptr1->suivant == NULL)
      {
        while (ptr2->suivant != NULL) {ptr2 = ptr2->suivant;}
      } else
      {
        while (ptr1->suivant != NULL) {ptr1 = ptr1->suivant;}
      }
      /*Problème de cohérence entre le cours et le code; A revoir*/

    }

    | IF condition ACCOLADE_G line ACCOLADE_D
    {
      //Idem
    }

    | IF condition ACCOLADE_G line ACCOLADE_D ELSE ACCOLADE_G line ACCOLADE_D
    {
      //Idem
    }
	//function
  ;

code_line: //Redondant avec statement
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

declaration:
   INT list_var
   {
     $$=$2;
     printf("declaration -> INT list_var\n");
   }
	//pour stencil
   ;


list_var:
   var VIRGULE list_var
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

var: //Redondant avec statement ?
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

   | IDENTIFIER ASSIGN expression
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
   IDENTIFIER ASSIGN expression
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
    expression PLUS expression
    { 
      $$.result = newtemp(&tds);
      struct symbol* arg1 = lookup(tds,$1.result->nom);
      struct symbol* arg2 = lookup(tds,$3.result->nom);
      struct quads* newQuads = quadsGen("+",arg1,arg2,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression + expression\n");
    }

  | expression MINUS expression
    { 
      $$.result = newtemp(&tds);
      struct symbol* arg1 = lookup(tds,$1.result->nom);
      struct symbol* arg2 = lookup(tds,$3.result->nom);
      struct quads* newQuads = quadsGen("-",arg1,arg2,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression - expression\n");
    }

  | expression DIV expression
    { 
      $$.result = newtemp(&tds);
      struct symbol* arg1 = lookup(tds,$1.result->nom);
      struct symbol* arg2 = lookup(tds,$3.result->nom);
      struct quads* newQuads = quadsGen("/",arg1,arg2,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression / expression\n");
    }


   | expression MUL expression
    { 
      $$.result = newtemp(&tds);
      struct symbol* arg1 = lookup(tds,$1.result->nom);
      struct symbol* arg2 = lookup(tds,$3.result->nom);
      struct quads* newQuads = quadsGen("*",arg1,arg2,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression * expression\n");
    }



  | PARENTHESE_G expression PARENTHESE_D
    {
      $$=$2;
      printf("expression -> ( expression )\n");
    }


  | MINUS expression
    {
      $$.result = newtemp(&tds);
      struct symbol* arg1 = newtemp(&tds);
      arg1->valeur = 0;
      struct symbol* arg2 = lookup(tds,$2.result->nom);
      struct quads* newQuads= quadsGen("-",arg1,arg2,$$.result);


      $$.code = quadsConcat(NULL,$2.code,newQuads);
      printf("expression -> - expression\n");

    }

  | INCR expression
    {
      $$.result = newtemp(&tds);
      struct symbol* arg1 = newtemp(&tds);
      arg1->valeur = 1;
      struct symbol* arg2 = lookup(tds,$2.result->nom);
      struct quads* newQuads= quadsGen("+",arg1,arg2,$$.result);


      $$.code = quadsConcat(NULL,$2.code,newQuads);
      printf("expression -> ++ expression\n");

    }

  | DECR expression
    {
      $$.result = newtemp(&tds);
      struct symbol* arg1 = newtemp(&tds);
      arg1->valeur = -1;
      struct symbol* arg2 = lookup(tds,$2.result->nom);
      struct quads* newQuads= quadsGen("+",arg1,arg2,$$.result);


      $$.code = quadsConcat(NULL,$2.code,newQuads);
      printf("expression -> -- expression\n");

    }

  | expression INCR
    {
      $$.result = newtemp(&tds);
      struct symbol* arg1 = newtemp(&tds);
      arg1->valeur = 1;
      struct symbol* arg2 = lookup(tds,$1.result->nom);
      struct quads* newQuads= quadsGen("+",arg1,arg2,$$.result);


      $$.code = quadsConcat(NULL,$1.code,newQuads);
      printf("expression -> expression ++\n");

    }

  | expression DECR
    {
      $$.result = newtemp(&tds);
      struct symbol* arg1 = newtemp(&tds);
      arg1->valeur = -1;
      struct symbol* arg2 = lookup(tds,$1.result->nom);
      struct quads* newQuads= quadsGen("+",arg1,arg2,$$.result);


      $$.code = quadsConcat(NULL,$1.code,newQuads);
      printf("expression -> expression --\n");

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

condition:  //condition booléenne
    IDENTIFIER EQUAL NUMBER
    {
      $$.result = newtemp(&tds);
      struct symbol* tmp = lookup(tds,$1);
      if(tmp != NULL)
      {
        printf("Redéclaration de %s\n",$1);
        return -1;
      }

      $$.result->valeur = (tmp->valeur == $3);
    }

  | IDENTIFIER NOTEQUAL NUMBER
    {
      $$.result = newtemp(&tds);
      struct symbol* tmp = lookup(tds,$1);
      if(tmp != NULL)
      {
        printf("Redéclaration de %s\n",$1);
        return -1;
      }

      $$.result->valeur = (tmp->valeur != $3);
    }

  | TRUE
    {
      $$.result = newtemp(&tds);
      $$.result->valeur = true;
    }

  | FALSE
    {
      $$.result = newtemp(&tds);
      $$.result->valeur = false;
    }

  | condition OR condition
    {
      complete($1.falselist, $3.code);
      $$.code = quadsConcat($1.code, $3.code, NULL);
      $$.truelist = concat($1.truelist, $3.truelist);
      $$.falselist = $1.falselist;
    }

  | condition AND condition
    {
      complete($1.truelist, $3.code);
      $$.code = quadsConcat($1.code, $3.code, NULL);
      $$.falselist = concat($1.falselist, $3.falselist);
      $$.truelist = $1.truelist;
    }

  | NOT condition
    {
      $$.code = $2.code;
      $$.falselist = $2.falselist;
      $$.truelist = $2.truelist;
    }
  //| OPAR condition CPAR {}
  
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
