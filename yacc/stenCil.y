%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "tds.h"
  #include "quads.h"
  #include "list_quads.h"

  void yyerror(char*);
  int yylex();

  struct symbol* tds = NULL;
  struct quads* quadsFinal = NULL;

  int nextquad = 1;

%}

%union{
	char* string;
	int value;

	struct{
		struct symbol* result;
		struct quads* code;
		struct list_quads* truelist;
		struct list_quads* falselist;
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
%token EQUAL
%token LOWEREQ
%token GREATEREQ
%token NOTEQUAL
%token AND
%token OR
%token INCR
%token DECR

%type <codegen>condition
%type <codegen>expression
%type <codegen>code_line
%type <codegen>statement
%type <codegen>line
%type <codegen>attribution
%type <codegen>declaration
%type <codegen>var
%type <codegen>list_var
%type <codegen>bloc
%type <value>tag
%type <value>tag_else


%left '(' ')'
%left '!' INCR DECR
%left '*' '/'
%left '-' '+' '$'
%left '<' '>' LESS MORE
%left EQUAL NOTEQUAL
%left AND
%left OR
%right '=' 

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
    code_line ';'
    {
      $$=$1;
      printf("statement -> code_line ;\n");
    }

    | WHILE tag condition tag bloc
    {
      //Begin
      

      //Concaténation de la truelist de la condition
      struct symbol* tmp = newtemp(&tds);
      tmp->valeur = $4;
      $$.truelist = complete_list_quads($3.truelist, tmp);
     
      //Ajout du goto begin
      tmp = newtemp(&tds);
      tmp->valeur = $2;
      struct quads* newQuads = quadsGen("goto", NULL, NULL, tmp);
      $$.code = quadsConcat($3.code,$5.code ,newQuads);

      //Concaténation de la falselist de la condition
      tmp = newtemp(&tds);
      tmp->valeur = nextquad;
      $$.falselist = complete_list_quads($3.falselist, tmp);
    }

    | IF condition tag bloc
    {
 

      //Concaténation de la truelist de la condition
      struct symbol* tmp = newtemp(&tds);
      tmp->valeur = $3;
      $$.truelist = complete_list_quads($2.truelist, tmp);
     
      $$.code = quadsConcat($2.code,$4.code,NULL);



      //Concaténation de la falselist de la condition
      tmp = newtemp(&tds);
      tmp->valeur = nextquad;
      $$.falselist = complete_list_quads($2.falselist, tmp);

    }

    | IF condition tag bloc ELSE tag_else bloc
    {
      //Concaténation de la truelist de la condition
      struct symbol* tmp = newtemp(&tds);
      tmp->valeur = $3;
      $$.truelist = complete_list_quads($2.truelist, tmp);
     
      tmp = newtemp(&tds);
      tmp->valeur = nextquad;
      struct quads* newQuads = quadsGen("goto", NULL, NULL, tmp);
      nextquad--;
      struct quads* codeTmp = quadsConcat($2.code,$4.code ,newQuads);

      //Concaténation de la falselist de la condition
      tmp = newtemp(&tds);
      tmp->valeur = $6;
      $$.falselist = complete_list_quads($2.falselist, tmp);

      $$.code = quadsConcat(codeTmp,$7.code,NULL);
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

   | IDENTIFIER '=' expression
   {
     struct symbol* tmp = lookup(tds,$1);

     if(tmp != NULL)
     {
       printf("Redéclaration de %s\n",$1);
       return -1;
     }


     $$.result = add(&tds,$1,false);
     struct quads* newQuads = quadsGen("move",$3.result,NULL,$$.result);
     $$.code = quadsConcat($3.code,NULL,newQuads);

   }
;


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

     //$$.result = add(&tds,$1,false);	//XXX opti: soit add ou renomage
     struct quads* newQuads = quadsGen("move",$3.result,NULL,tmp);
     $$.code = quadsConcat($3.code,NULL,newQuads);
     printf("attribution -> ID = expression\n");
   }
  ;



bloc:
   '{' line '}'
   {
      $$ = $2;
     printf("bloc -> { line }\n");
   }



expression:
    expression '+' expression
    { 
      $$.result = newtemp(&tds);
      struct quads* newQuads = quadsGen("+",$1.result,$3.result,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression + expression\n");
    }

  | expression '-' expression
    { 
      $$.result = newtemp(&tds);
      struct quads* newQuads = quadsGen("-",$1.result,$3.result,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression - expression\n");
    }

  | expression '/' expression
    { 
      $$.result = newtemp(&tds);
      struct quads* newQuads = quadsGen("/",$1.result,$3.result,$$.result);


      $$.code = quadsConcat($1.code,$3.code,newQuads);
      printf("expression -> expression / expression\n");
    }


   | expression '*' expression
    { 
      $$.result = newtemp(&tds);
      struct quads* newQuads = quadsGen("*",$1.result,$3.result,$$.result);


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
      struct quads* newQuads= quadsGen("-",arg1,$2.result,$$.result);


      $$.code = quadsConcat(NULL,$2.code,newQuads);
      printf("expression -> - expression\n");

    }

  | INCR expression
    {
      $$.result = newtemp(&tds);
      struct symbol* arg = newtemp(&tds);
      arg->valeur = 1;
      struct quads* newQuads= quadsGen("+",$2.result,arg,$$.result);


      $$.code = quadsConcat(NULL,$2.code,newQuads);
      printf("expression -> ++ expression\n");

    }

  | DECR expression
    {
      $$.result = newtemp(&tds);
      struct symbol* arg = newtemp(&tds);
      arg->valeur = 1;
      struct quads* newQuads= quadsGen("-",$2.result,arg,$$.result);


      $$.code = quadsConcat(NULL,$2.code,newQuads);
      printf("expression -> -- expression\n");

    }

  | expression INCR
      {
      $$.result = newtemp(&tds);
      struct symbol* arg = newtemp(&tds);
      arg->valeur = 1;
      struct quads* newQuads= quadsGen("+",$1.result,arg,$$.result);


      $$.code = quadsConcat(NULL,$1.code,newQuads);
      printf("expression -> expression ++\n");

    }

  | expression DECR
    {
      $$.result = newtemp(&tds);
      struct symbol* arg = newtemp(&tds);
      arg->valeur = 1;
      struct quads* newQuads= quadsGen("-",$1.result,arg,$$.result);


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


      $$.code = NULL;	//TODO load imediate
      printf("expression -> NUMBER (%d)\n", $1);
    }
  ;

condition:  //condition booléenne
    expression EQUAL expression
    {
      struct quads* newQuads = quadsGen("==",$1.result,$3.result,NULL);
      $$.truelist = new_list_quads(newQuads);

      struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

      newQuads = quadsGen("goto",NULL,NULL,NULL);
      $$.falselist = new_list_quads(newQuads);

      $$.code = quadsConcat(tmp,NULL,newQuads);

      printf("condition -> expression == expression\n");
    }


    | expression NOTEQUAL expression
    {
      struct quads* newQuads = quadsGen("!=",$1.result,$3.result,NULL);
      $$.truelist = new_list_quads(newQuads);

      struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

      newQuads = quadsGen("goto",NULL,NULL,NULL);
      $$.falselist = new_list_quads(newQuads);

      $$.code = quadsConcat(tmp,NULL,newQuads);

      printf("condition -> expression != expression\n");
    }


    | expression GREATEREQ expression
    {
      struct quads* newQuads = quadsGen(">=",$1.result,$3.result,NULL);
      $$.truelist = new_list_quads(newQuads);

      struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

      newQuads = quadsGen("goto",NULL,NULL,NULL);
      $$.falselist = new_list_quads(newQuads);

      $$.code = quadsConcat(tmp,NULL,newQuads);

      printf("condition -> expression >= expression\n");
    }


    | expression '>' expression
    {
      struct quads* newQuads = quadsGen(">",$1.result,$3.result,NULL);
      $$.truelist = new_list_quads(newQuads);

      struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

      newQuads = quadsGen("goto",NULL,NULL,NULL);
      $$.falselist = new_list_quads(newQuads);

      $$.code = quadsConcat(tmp,NULL,newQuads);

      printf("condition -> expression > expression\n");
    }


    | expression LOWEREQ expression
    {
      struct quads* newQuads = quadsGen("<=",$1.result,$3.result,NULL);
      $$.truelist = new_list_quads(newQuads);

      struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

      newQuads = quadsGen("goto",NULL,NULL,NULL);
      $$.falselist = new_list_quads(newQuads);

      $$.code = quadsConcat(tmp,NULL,newQuads);

      printf("condition -> expression <= expression\n");
    }



    | expression '<' expression
    {
      struct quads* newQuads = quadsGen("<",$1.result,$3.result,NULL);
      $$.truelist = new_list_quads(newQuads);

      struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

      newQuads = quadsGen("goto",NULL,NULL,NULL);
      $$.falselist = new_list_quads(newQuads);

      $$.code = quadsConcat(tmp,NULL,newQuads);

      printf("condition -> expression < expression\n");
    }



  | TRUE
    {
	//XXX sert a rien?
      $$.result = newtemp(&tds);
      $$.result->valeur = true;
    }

  | FALSE
    {
	//XXX sert a rien?
      $$.result = newtemp(&tds);
      $$.result->valeur = false;
    }

  | condition OR tag condition
    {
      struct symbol* tmp = newtemp(&tds);
      tmp->valeur = $3;
      complete_list_quads($1.falselist,tmp);
      $$.code = quadsConcat($1.code, $4.code, NULL);
      $$.truelist = concat_list_quads($1.truelist, $4.truelist);
      $$.falselist = $4.falselist;

      printf("condition -> condition || tag condition\n");
    }

  | condition AND tag condition
    {
      struct symbol* tmp = newtemp(&tds);
      tmp->valeur = $3;
      complete_list_quads($1.truelist, tmp);
      $$.code = quadsConcat($1.code, $4.code, NULL);
      $$.falselist = concat_list_quads($1.falselist, $4.falselist);
      $$.truelist = $4.truelist;

      printf("condition -> condition && tag condition\n");
    }

  | '!' condition
    {
      $$.code = $2.code;
      $$.falselist = $2.truelist;
      $$.truelist = $2.falselist;

      printf("condition -> ! condition\n");
    }




  | '(' condition ')' {$$ = $2;

      printf("condition -> (condition)\n");
     }

  
  ;

tag:
    {
      $$ = nextquad;
      printf("Tag\n");
    }

tag_else:
    {
      nextquad++;
      $$ = nextquad;
      printf("Tag else\n");
    }

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
