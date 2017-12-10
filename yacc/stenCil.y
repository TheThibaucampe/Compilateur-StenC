%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "enum.h"
  #include "tds.h"
  #include "quads.h"
  #include "list_quads.h"
  #include "tradCode.h"
  #include "dim.h"
  #include "listNumber.h"
  #include "stencil.h"

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
		union {
			struct {
				struct list_quads* truelist;
				struct list_quads* falselist;
			};
			struct {
				int nb_dim;
				struct symbol* decal;
			};
		};
	} codegen;

	struct{
		int width;
		struct listNumber* list_number;
		struct dim* list_dim;
		int nb_dim;
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
%token DIM_SEPARATOR
%token <string>STRING

%type <codegen>condition
%type <codegen>expression
%type <codegen>code_line
%type <codegen>statement
%type <codegen>line
%type <codegen>attribution
%type <codegen>declaration
%type <codegen>var_int
%type <codegen>var_stencil
%type <codegen>list_var_int
%type <codegen>list_var_stencil
%type <codegen>bloc
%type <codegen>avancement_for
%type <value>tag
%type <value>tag_else
%type <tab>array
%type <tab>list_array 
%type <tab>list_number
%type <codegen>variable_attribution
%type <codegen>index_attribution
%type <codegen>index_declaration
%type <codegen>variable_declaration
%type <codegen>variable
%type <codegen>main

%left DIM_SEPARATOR
%left '(' ')'
%left '!' INCR DECR
%left '*' '/' '$'
%left '-' '+' 
%left '<' '>' LOWEREQ GREATEREQ
%left EQUAL NOTEQUAL
%left AND
%left OR
%right '=' 

%start axiom

%%

axiom:
  main
    {
      quadsFinal = $1.code;
      printf("Match :-) !\n");
      return 0;
    }
;


main:
  INT MAIN '(' ')' bloc
  {
    $$=$5;
  }


bloc:
  '{' line '}'
  {
    $$ = $2;
    printf("bloc -> { line }\n");
  }

 /*  | statement
   {
     $$=$1;
     printf("bloc ->statement\n");
   } TODO Erreur shift/reduce */ 
;


line:
  line statement
  {
    $$.code = quadsConcat($1.code,$2.code,NULL);
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
    struct symbol* tmp = newLabel(&tds,$4);
    $$.truelist = complete_list_quads($3.truelist, tmp);

    //Ajout du goto begin
    tmp = newLabel(&tds,$2);
    struct quads* newQuads = quadsGen("j", NULL, NULL, tmp);
    $$.code = quadsConcat($3.code,$5.code ,newQuads);

    //Concaténation de la falselist de la condition
    tmp = newLabel(&tds,nextquad);
    $$.falselist = complete_list_quads($3.falselist, tmp);
  }

  | IF condition tag bloc
  {
    //Concaténation de la truelist de la condition
    struct symbol* tmp = newLabel(&tds,$3);
    $$.truelist = complete_list_quads($2.truelist, tmp);

    //Concaténation du code de bloc
    $$.code = quadsConcat($2.code,$4.code,NULL);

    //Concaténation de la falselist de la condition
    tmp = newLabel(&tds,nextquad);
    $$.falselist = complete_list_quads($2.falselist, tmp);
  }

  | IF condition tag bloc ELSE tag_else bloc
  {
    //Concaténation de la truelist de la condition
    struct symbol* tmp = newLabel(&tds,$3);
    $$.truelist = complete_list_quads($2.truelist, tmp);

    //Ajout d'un goto
    tmp = newLabel(&tds,nextquad);
    struct quads* newQuads = quadsGen("j", NULL, NULL, tmp);
    nextquad--;

    //Concaténation des blocs
    struct quads* codeTmp = quadsConcat($2.code,$4.code ,newQuads);

    //Concaténation de la falselist de la condition
    tmp = newLabel(&tds,$6);
    $$.falselist = complete_list_quads($2.falselist, tmp);
    $$.code = quadsConcat(codeTmp,$7.code,NULL);
  }

  | FOR '(' attribution ';' tag condition ';' tag avancement_for tag {nextquad-=($10-$8);} ')' tag bloc
  //TODO avancement for pourrai etre un code line??
  {
    //Nouveau calcul du nextquad
    nextquad+=($10-$8);

    //Concaténation de la truelist de la condition
    struct symbol* tmp = newLabel(&tds,$13);
    $$.truelist = complete_list_quads($6.truelist, tmp);
    struct quads* code_tmp = quadsConcat($3.code,$6.code,$14.code);

    //Ajout du goto begin
    tmp = newLabel(&tds,$5);
    struct quads* newQuads = quadsGen("j", NULL, NULL, tmp);
    code_tmp = quadsConcat(code_tmp,$9.code ,newQuads);

    //Concaténation de la falselist de la condition
    tmp = newLabel(&tds,nextquad);
    $$.falselist = complete_list_quads($6.falselist, tmp);
    
    $$.code = code_tmp;

    printf("statement -> for\n");
  }
;

avancement_for:
  attribution
  {
    $$=$1;
    printf("avencement_for -> attribution\n");
  }

  | expression
  {
    $$=$1;
    printf("avencement_for -> expression\n");
  }
;


tag:
  {
    $$ = nextquad;
    printf("Tag\n");
  }
;

tag_else:
  {
    nextquad++;
    $$ = nextquad;
    printf("Tag else\n");
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

  | PRINTF '(' STRING ')'
  {
    struct symbol* tmp = newtemp(&tds);
    tmp->string = $3;
    tmp->type = STRING;
    $$.code = quadsGen("printf",NULL,NULL,tmp);
    printf("code_ligne -> PRINTF '(' STRING ')'\n");
  }

  | PRINTI '(' variable ')'
  {
    struct quads* newQuads = quadsGen("printi",NULL,NULL,$3.result);
    $$.code = quadsConcat($3.code,NULL,newQuads);
    printf("code_ligne -> PRINTI '(' variable ')'\n");
  }

  | expression
  {
    $$=$1;
    printf("code_ligne -> expression\n");
  }

  | RETURN expression
  {
    $$=$2;
    printf("code_ligne -> RETURN expression\n");
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

list_var_int:
  var_int ',' list_var_int
  {
    $$.code = quadsConcat($1.code,$3.code,NULL);
    printf("list_var_int -> list_var_int var_int\n");
  }

  | var_int
  {
    $$=$1;
    printf("list_var_int -> var_int\n");
}
;

var_int:
  variable_declaration
  {
    $$=$1;
    printf("var_int -> variable_declaration\n");
  }

  | variable_declaration '=' expression
  {
    $$=$1;
    if($1.decal != NULL)
    {
      printf("Erreur, %s est un tableau, impossible de mettre un int\n",$1.result->name);
    }
    struct quads* newQuads = quadsGen("move",$3.result,NULL,$$.result);
    $$.code = quadsConcat($3.code,NULL,newQuads);

    printf("var_int -> variable = expression\n");
  }

  | variable_declaration '=' array
  {
    $$ = $1;
    if($1.decal == NULL)
    {
      printf("Erreur, mise de tableau dans variable int\n");
      exit(-1);
    }
    checkDims($1.result->size_dim,$3.list_dim->next);
    $$.result->array_value = translateListToTab($3.list_number);
  }
;


list_var_stencil:
  var_stencil ',' list_var_stencil
  {
    $$.code = quadsConcat($1.code,$3.code,NULL);
    printf("list_var_stencil -> list_var_stencil var_stencil\n");
  }

  | var_stencil
  {
    $$=$1;
    printf("list_var_stencil -> var_stencil\n");
  }
;

var_stencil:
  IDENTIFIER '{' NUMBER ',' NUMBER '}' '=' array
  {
    struct symbol* tmp = lookup(tds,$1);

    if(tmp != NULL)
    {
      printf("Redéclaration de %s\n",$1);
      exit(-1);
    }

    checkDimsStencil($8.list_dim, $3, $5);

    $$.result = add(&tds, $1, false);
    $$.result->type = STENCIL_TYPE;

    $$.result->array_value = translateListToTab($8.list_number); 
    $$.result->length = $8.list_number->size;

    $$.result->is_array = true;
    $$.result->radius = $3;
    $$.result->nb_dim = $5;
  }
;

variable:
IDENTIFIER
  {
    struct symbol* tmp = lookup(tds,$1);

    if(tmp == NULL)
    {
     printf("ID: première utilisation de %s sans déclaration\n",$1);
     return -1;
    }


    $$.result = tmp;
    $$.code = NULL;

    printf("variable -> ID\n");
  }

  | index_attribution ']'
  {
    $$.result = newtemp(&tds);
    struct quads* newQuads = quadsGen("load_from_tab",$1.result,$1.decal,$$.result);
    $$.code = quadsConcat($1.code,NULL,newQuads);

    printf("variable -> ID[expression]\n");
  }
; 

variable_declaration:
  IDENTIFIER
  {
    struct symbol* tmp = lookup(tds,$1);

    if(tmp != NULL)
    {
      printf("Erreur, redéclaration de %s\n",$1);
      exit(-1);
    }

    $$.result = add(&tds, $1, false);
    $$.result->type = INT_TYPE;
    $$.code = NULL;

    printf("variable_declaration -> ID\n");
  }

  | index_declaration ']'
  {
    $1.result->length = $1.decal->value;
    $1.result->array_value = malloc($1.decal->value*sizeof(int));
    $1.code = NULL;
    printf("variable_declaration -> index_declaration ]\n");
  }
;

index_declaration:
  index_declaration DIM_SEPARATOR NUMBER	//TODO calcul des expression
  {
    add_dim($1.result,$3);
    $$.nb_dim = $1.nb_dim+1;
    $$.result = $1.result;
    $$.decal->value = $1.decal->value*$3;
    $$.code = $1.code;

    printf("index_declaration -> index_declaration , NUMBER (%d)\n",$3);
  }

  | IDENTIFIER '[' NUMBER
  {
    struct symbol* tmp = lookup(tds,$1);

    if(tmp != NULL)
    {
      printf("Erreur, redeclaration de %s\n",$1);
      exit(-1);
    }

    $$.result = add(&tds,$1,false);
    $$.result->is_array = true;
    add_dim($$.result,$3);
    $$.decal = (struct symbol*) malloc(sizeof(struct symbol));
    $$.decal->value = $3;
    $$.code = NULL;
    $$.nb_dim = 1;

    printf("index_declaration -> ID [ NUMBER (%d)\n",$3);
  }
;

attribution:	//TODO derivation inutile
  variable_attribution '=' expression
  {
    if($1.decal == NULL)
    {
      //$$.result = add(&tds,$1,false);	//XXX opti: soit add ou renomage
      struct quads* newQuads = quadsGen("move",$3.result,NULL,$1.result);
      $$.code = quadsConcat($3.code,NULL,newQuads);
    }
    else
    {
      struct quads* newQuads = quadsGen("store_into_tab",$3.result,$1.decal,$1.result);
      $$.code = quadsConcat($1.code,$3.code,newQuads);
    }
    printf("attribution -> variable = expression\n");
  }
;

variable_attribution:
  IDENTIFIER
  {
    struct symbol* tmp = lookup(tds,$1);

    if(tmp == NULL)
    {
      printf("ID: première utilisation de %s sans déclaration\n",$1);
      exit(-1);
    }
    if(tmp->is_constant == true)
    {
      printf("Tentative de modification d'une constante\n");
      exit(-1);
    }

    $$.result = tmp;
    $$.code = NULL;

    printf("variable -> ID\n");
  }

  | index_attribution ']'
  {
    $$ = $1;
    printf("variable -> ID[expression]\n");
  }
;

index_attribution:
  index_attribution DIM_SEPARATOR expression
  {
    $$.nb_dim = $1.nb_dim+1;
    struct symbol* symbol_size_dim = newtemp(&tds);
    symbol_size_dim->value = dim_size(tds,$1.result->name,$$.nb_dim);
    struct symbol* tmp1 = newtemp(&tds);
    struct symbol* tmp2 = newtemp(&tds);
    struct quads* quads1 = quadsGen("mul",$1.decal,symbol_size_dim,tmp1);
    struct quads* quads2 = quadsGen("addu",tmp1,$3.result,tmp2);
    $$.code = quadsConcat($1.code,$3.code,NULL);
    $$.code = quadsConcat($$.code,quads1,quads2);
    $$.result = $1.result;
    $$.decal = tmp2;

    printf("index_attribution -> index_attribution , expression\n");
  }

  | IDENTIFIER '[' expression
  {
    $$.result = lookup(tds,$1);

    if($$.result == NULL)
    {
      printf("index: première utilisation de %s sans déclaration\n",$1);
      exit(-1);
    }
    if($$.result->is_constant == true)
    {
      printf("Tentative de modification de la constante %s\n",$1);
      exit(-1);
    }

    $$.decal = $3.result;
    $$.code = $3.code;
    $$.nb_dim = 1;

    printf("index_attribution -> ID [ expression\n");
  }
;

array:
  '{' list_array '}'
  {
    $$ = $2;
    $$.list_dim = appendToListDim($2.list_dim,1);
    
    printf("array -> list_array\n");
  }
;

list_array:
  array ',' list_array
  {
    checkDims($1.list_dim->next,$3.list_dim->next);

    $$.list_dim = $1.list_dim;
    $$.list_dim->size = $3.list_dim->size + 1;
    $$.list_number = concatListNumber($1.list_number,$3.list_number);

    printf("list_array -> array ',' list_array\n");
  }

  | array
  {
    $$ = $1;
    printf("list_array -> array\n");
  }

  | list_number
  {
    $$=$1;
    printf("list_array -> list_number\n");
  }
;

list_number:
  NUMBER
  {
    struct listNumber* tmp = malloc(sizeof(struct listNumber));
    tmp->begin = NULL;
    $$.list_dim = appendToListDim(NULL,1);
    $$.list_number = addNumber(tmp,$1);
    $$.width = 1;
    printf("list_array -> NUMBER (%d)\n", $1);

  }

  | list_number ',' NUMBER
  {
    $$.list_number = addNumber($1.list_number,$3);
    $$.list_dim = $1.list_dim;
    $$.list_dim->size = $1.list_dim->size + 1;
    printf("list_array -> NUMBER ',' list_array\n");
 
  }
;

expression:
  expression '+' expression
  { 
    $$.result = newtemp(&tds);
    struct quads* newQuads = quadsGen("addu",$1.result,$3.result,$$.result);
    $$.code = quadsConcat($1.code,$3.code,newQuads);
    printf("expression -> expression + expression\n");
  }

  | expression '-' expression
  { 
    $$.result = newtemp(&tds);
    struct quads* newQuads = quadsGen("subu",$1.result,$3.result,$$.result);
    $$.code = quadsConcat($1.code,$3.code,newQuads);
    printf("expression -> expression - expression\n");
  }

  | expression '/' expression
  { 
    $$.result = newtemp(&tds);
    struct quads* newQuads = quadsGen("div",$1.result,$3.result,$$.result);
    $$.code = quadsConcat($1.code,$3.code,newQuads);
    printf("expression -> expression / expression\n");
  }


  | expression '*' expression
  { 
    $$.result = newtemp(&tds);
    struct quads* newQuads = quadsGen("mul",$1.result,$3.result,$$.result);
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
    arg1->value = 0;
    struct quads* newQuads= quadsGen("subu",arg1,$2.result,$$.result);
    $$.code = quadsConcat(NULL,$2.code,newQuads);
    printf("expression -> - expression\n");

  }
  | INCR expression
  {
    //XXX instr addi
    $$.result = $2.result;
    struct symbol* arg = newtemp(&tds);
    arg->value = 1;
    struct quads* newQuads= quadsGen("addu",$2.result,arg,$2.result);
    $$.code = quadsConcat(NULL,$2.code,newQuads);
    printf("expression -> ++ expression\n");
  }

  | DECR expression
  {
    //XXX instr subi
    $$.result = $2.result;
    struct symbol* arg = newtemp(&tds);
    arg->value = 1;
    struct quads* newQuads= quadsGen("subu",$2.result,arg,$2.result);
    $$.code = quadsConcat(NULL,$2.code,newQuads);
    printf("expression -> -- expression\n");
  }

  | expression INCR
  {
    //XXX instr addi
    $$.result = $1.result;
    struct symbol* arg = newtemp(&tds);
    arg->value = 1;
    struct quads* newQuads= quadsGen("addu",$1.result,arg,$1.result);
    $$.code = quadsConcat(NULL,$1.code,newQuads);
    printf("expression -> expression ++\n");
  }

  | expression DECR
  {
    //XXX instr subi
    $$.result = $1.result;
    struct symbol* arg = newtemp(&tds);
    arg->value = 1;
    struct quads* newQuads= quadsGen("subu",$1.result,arg,$1.result);
    $$.code = quadsConcat(NULL,$1.code,newQuads);
    printf("expression -> expression --\n");

  }

  | variable
  {
    $$.result = $1.result;
    $$.code = $1.code;
    printf("expression -> variable\n");
  }

  | NUMBER
  {
    $$.result = newtemp(&tds);
    $$.result->value = $1;
    $$.code = NULL;
    printf("expression -> NUMBER (%d)\n", $1);
  }

  | IDENTIFIER '$' index_attribution ']'
  {
    struct symbol* stencil = lookup(tds,$1);
    if(stencil == NULL)
    {
      printf("Erreur, %s n'est pas déclaré\n",$1);
      exit(-1);
    }
    if(stencil->type != STENCIL_TYPE)
    {
      printf("Erreur %s n'est pas un stencil\n",$1);
      exit(-1);
    }

    int i;
    int nb_element = total_element(stencil->radius,stencil->nb_dim);
    struct symbol* tmp1 = newtemp(&tds);
    struct symbol* tmp2 = newtemp(&tds);
    struct symbol* tmp3 = newtemp(&tds);
    struct symbol* tmp4 = newtemp(&tds);
    struct symbol* tmp5 = newtemp(&tds);
    tmp5->value = 0;

    for(i=0;i<nb_element;i++)
    {
      struct symbol* shift = newtemp(&tds);
      shift->value = decalage($3.result->size_dim,stencil->radius,stencil->nb_dim,i);

      struct symbol* iterator = newtemp(&tds);
      iterator->value = i;

      struct quads* newQuads1 = quadsGen("addu",shift,$3.decal,tmp1);
      struct quads* newQuads2 = quadsGen("load_from_tab",$3.result,tmp1,tmp2);
      struct quads* newQuads3 = quadsGen("load_from_tab",stencil,iterator,tmp3);
      struct quads* newQuads4 = quadsGen("mul",tmp2,tmp3,tmp4);
      struct quads* newQuads5= quadsGen("addu",tmp4,tmp5,tmp5);

      $$.code = quadsConcat($3.code,newQuads1,newQuads2);
      $$.code = quadsConcat($$.code,newQuads3,newQuads4);
      $$.code = quadsConcat($$.code,newQuads5,NULL);
    }

    $$.result = tmp5;
    printf("expression -> ID $ index_attribution ]\n");
  }

  | index_attribution ']' '$' IDENTIFIER
  {
    struct symbol* stencil = lookup(tds,$4);
    if(stencil == NULL)
    {
      printf("Erreur, %s n'est pas déclaré\n",$4);
      exit(-1);
    }
    if(stencil->type != STENCIL_TYPE)
    {
      printf("Erreur %s n'est pas un stencil\n",$4);
      exit(-1);
    }

    int i;
    int nb_element = total_element(stencil->radius,stencil->nb_dim);
    struct symbol* tmp1 = newtemp(&tds);
    struct symbol* tmp2 = newtemp(&tds);
    struct symbol* tmp3 = newtemp(&tds);
    struct symbol* tmp4 = newtemp(&tds);
    struct symbol* tmp5 = newtemp(&tds);
    tmp5->value = 0;

    for(i=0;i<nb_element;i++)
    {
      struct symbol* shift = newtemp(&tds);
      shift->value = decalage($1.result->size_dim,stencil->radius,stencil->nb_dim,i);

      struct symbol* iterator = newtemp(&tds);
      iterator->value = i;

      struct quads* newQuads1 = quadsGen("addu",shift,$1.decal,tmp1);
      struct quads* newQuads2 = quadsGen("load_from_tab",$1.result,tmp1,tmp2);
      struct quads* newQuads3 = quadsGen("load_from_tab",stencil,iterator,tmp3);
      struct quads* newQuads4 = quadsGen("mul",tmp2,tmp3,tmp4);
      struct quads* newQuads5= quadsGen("addu",tmp4,tmp5,tmp5);

      $$.code = quadsConcat($1.code,newQuads1,newQuads2);
      $$.code = quadsConcat($$.code,newQuads3,newQuads4);
      $$.code = quadsConcat($$.code,newQuads5,NULL);
    }

    $$.result = tmp5;
    printf("expression -> index_attribution ] $ ID\n");
  }
;

condition:  //condition booléenne
  expression EQUAL expression
  {
    struct quads* newQuads = quadsGen("beq",$1.result,$3.result,NULL);
    $$.truelist = new_list_quads(newQuads);
    struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

    newQuads = quadsGen("j",NULL,NULL,NULL);
    $$.falselist = new_list_quads(newQuads);
    $$.code = quadsConcat(tmp,NULL,newQuads);

    printf("condition -> expression == expression\n");
  }

  | expression NOTEQUAL expression
  {
    struct quads* newQuads = quadsGen("bne",$1.result,$3.result,NULL);
    $$.truelist = new_list_quads(newQuads);
    struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

    newQuads = quadsGen("j",NULL,NULL,NULL);
    $$.falselist = new_list_quads(newQuads);
    $$.code = quadsConcat(tmp,NULL,newQuads);

    printf("condition -> expression != expression\n");
  }

  | expression GREATEREQ expression
  {
    struct quads* newQuads = quadsGen("bge",$1.result,$3.result,NULL);
    $$.truelist = new_list_quads(newQuads);
    struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

    newQuads = quadsGen("j",NULL,NULL,NULL);
    $$.falselist = new_list_quads(newQuads);
    $$.code = quadsConcat(tmp,NULL,newQuads);

    printf("condition -> expression >= expression\n");
  }

  | expression '>' expression
  {
    struct quads* newQuads = quadsGen("bgt",$1.result,$3.result,NULL);
    $$.truelist = new_list_quads(newQuads);
    struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

    newQuads = quadsGen("j",NULL,NULL,NULL);
    $$.falselist = new_list_quads(newQuads);
    $$.code = quadsConcat(tmp,NULL,newQuads);

    printf("condition -> expression > expression\n");
  }

  | expression LOWEREQ expression
  {
    struct quads* newQuads = quadsGen("ble",$1.result,$3.result,NULL);
    $$.truelist = new_list_quads(newQuads);
    struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

    newQuads = quadsGen("j",NULL,NULL,NULL);
    $$.falselist = new_list_quads(newQuads);
    $$.code = quadsConcat(tmp,NULL,newQuads);

    printf("condition -> expression <= expression\n");
  }

  | expression '<' expression
  {
    struct quads* newQuads = quadsGen("blt",$1.result,$3.result,NULL);
    $$.truelist = new_list_quads(newQuads);
    struct quads* tmp = quadsConcat($1.code,$3.code,newQuads);

    newQuads = quadsGen("j",NULL,NULL,NULL);
    $$.falselist = new_list_quads(newQuads);
    $$.code = quadsConcat(tmp,NULL,newQuads);

    printf("condition -> expression < expression\n");
  }

  | condition OR tag condition
  {
    struct symbol* tmp = newtemp(&tds);
    tmp->value = $3;
    complete_list_quads($1.falselist,tmp);
    $$.code = quadsConcat($1.code, $4.code, NULL);
    $$.truelist = concat_list_quads($1.truelist, $4.truelist);
    $$.falselist = $4.falselist;

    printf("condition -> condition || tag condition\n");
  }

  | condition AND tag condition
  {
    struct symbol* tmp = newtemp(&tds);
    tmp->value = $3;
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

  tradCodeFinal("out.s",quadsFinal,tds);

  //Free



  //lex_free();

  return 0;
}
