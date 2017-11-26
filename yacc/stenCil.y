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
    int width;
    int height;
    char* type;
	} codegen;

  struct{
    int width;
    int height;
    int** tab;
  } tab;
}


%token <string>IDENTIFIER
%token <value>NUMBER
%token <value>TRUE
%token <value>FALSE
%token <tab>STENC
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
%type <codegen>var_int
%type <codegen>var_stencil
%type <codegen>list_var
%type <codegen>list_var_int
%type <codegen>list_var_stencil
%type <codegen>bloc
%type <value>tag
%type <value>tag_else
%type <tab>array
%type <tab>list_array 


%left '(' ')'
%left '!' INCR DECR
%left '*' '/'
%left '-' '+' '$'
%left '<' '>' LOWEREQ GREATEREQ
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
     
      //Concaténation du code de bloc
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
  	
    //Function
    | INT IDENTIFIER '(' list_var ')' '{' line RETURN NUMBER ';' '}'
    {

    }

    | STENCIL IDENTIFIER '(' list_var ')' '{' line RETURN STENC ';' '}'
    {
      
    }
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

declaration:
   INT list_var_int
   {
     $$=$2;
     printf("declaration -> INT list_var_int\n");
   }

	| STENCIL list_var_stencil
   {
     $$=$2;
     printf("declaration -> STENCIL list_var_stencil\n");
   }
   ;

list_var:
    list_var_int
    {
     $$=$1;
     printf("list_var -> list_var_int\n");
    }

    |list_var_stencil
    {
      $$=$1;
      printf("list_var -> list_var_stencil\n");
    }

list_var_int:
   var_int ',' list_var_int
   {
     $$.code = quadsConcat($1.code,$3.code,NULL);
     //XXX result?
     printf("list_var_int -> list_var_int var_int\n");
   }

   | var_int
   {
     $$=$1;
     printf("list_var_int -> var_int\n");
   }
  ;

var_int:
   IDENTIFIER
   {
     struct symbol* tmp = lookup(tds,$1);

     if(tmp != NULL)
     {
       printf("Redéclaration de %s\n",$1);
       return -1;
     }
     $$.result = add(&tds, $1, false);
     $$.type = "int";
     printf("var_int ->ID\n");
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
     $$.type = "int";
   }
;

list_var_stencil:
   var_stencil ',' list_var_stencil
   {
     $$.code = quadsConcat($1.code,$3.code,NULL);
     //XXX result?
     printf("list_var_stencil -> list_var_stencil var_stencil\n");
   }

   | var_stencil
   {
     $$=$1;
     printf("list_var_stencil -> var_stencil\n");
   }
  ;

var_stencil:
   IDENTIFIER '{' NUMBER ',' NUMBER '}'
   {
     struct symbol* tmp = lookup(tds,$1);

     if(tmp != NULL)
     {
       printf("Redéclaration de %s\n",$1);
       return -1;
     }
     /*$$.result = add(&tds, $1, false);
     printf("var_stencil ->ID\n");
     //XXX code*/
     $$.type = "stencil";
     $$.height = $3;
     $$.width = $5;
   }

   | IDENTIFIER '{' NUMBER ',' NUMBER '}' '=' array
   {
     struct symbol* tmp = lookup(tds,$1);

     if(tmp != NULL)
     {
       printf("Redéclaration de %s\n",$1);
       return -1;
     }

     //Verify that the array's size matches stencil definition
     if (($3 != $8.height) || (2*$5 + 1 != $8.width))
     {
        printf("Le tableau ne correspond pas à la définition du stencil");
        return -1;
     }

     /*$$.result = add(&tds,$1,false);
     struct quads* newQuads = quadsGen("move",$3.result,NULL,$$.result);
     $$.code = quadsConcat($3.code,NULL,newQuads);*/
     $$.type = "stencil";
     $$.height = $3;
     $$.width = $5;
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

array:
  '{' list_array '}'
  {
    $$.height = $2.height + 1;
    printf("array -> list_array\n");
  }

list_array:
  NUMBER
  {
    //$$.result = newtemp(&tds);
    //$$.result->valeur = $1;

    //$$.code = NULL; //TODO load imediate
    $$.width = 1;
    $$.height = 0;
    printf("list_array -> NUMBER (%d)\n", $1);
  }

  | NUMBER ',' list_array
  {
    //TODO

    $$.width = $$.width + 1;
    printf("list_array -> NUMBER ',' list_array\n");
  }

  | array ',' list_array
  {
    //TODO

    $$.width = $$.width + 1;
    $$.height = $$.height + 1;
    printf("list_array -> array ',' list_array\n");
  }

  | array
  {
    //TODO

    $$.height = 1;
    printf("list_array -> array\n");
  }

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

  | STENC
    {
      $$.result = newtemp(&tds);
      //TODO

      $$.code = NULL; //TODO load imediate
      printf("expression -> STENC\n");
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
	//XXX sert a rien? //Non, il faut pouvoir faire remonter la valeur booléenne
      $$.result = newtemp(&tds);
      $$.result->valeur = true;
    }

  | FALSE
    {
	//XXX sert a rien? //Non, il faut pouvoir faire remonter la valeur booléenne
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




  | '(' condition ')'
  {
    $$ = $2;
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
