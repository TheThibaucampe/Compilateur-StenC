#include "quads.h"

//Generate a quad
struct quads* quadsGen(char* op, struct symbol* arg1, struct symbol* arg2, struct symbol* res)
{
	struct quads* new_quads = malloc(sizeof(struct quads));
	new_quads->op = strdup(op);
	new_quads->arg1 = arg1;
	new_quads->arg2 = arg2;
	new_quads->res = res;
	new_quads->next = NULL;

	//Increment nextquad for the next quad's value
	nextquad++;

	return new_quads;
}

//Concatenate 3 lists of quads, it handles cases where a list is empty
struct quads* quadsConcat(struct quads* quads1, struct quads* quads2, struct quads* quads3)
{
	struct quads* curseur = quads1;
	struct quads* retour = quads1;

	if(quads1 != NULL)
	{
		while(curseur->next != NULL)
		{
			curseur = curseur->next;
		}
		curseur->next = quads2;
	}
	else
	{
		retour = quads2;
	}

	if(quads2 != NULL)
	{
		curseur = quads2;
		while(curseur->next != NULL)
		{
			curseur = curseur->next;
		}

		curseur->next = quads3;
	}
	else if(quads2 == NULL && NULL == quads1)
	{
		retour = quads3;
	}
	else
	{
		curseur->next = quads3;
	}

	return retour;
}

//Print all quads
void quadsPrint(struct quads* quads)
{
	struct quads* curseur = quads;
	int i=1;
	while(curseur != NULL)
	{
		printf("%d ",i); //Print a number of line
		if(strcmp(curseur->op,"j") == 0 || strcmp(curseur->op,"printf") ==0 || strcmp(curseur->op,"printi") ==0 || strcmp(curseur->op,"return") == 0)
		printf("%s %s\n",curseur->op,curseur->res->name);

		else if(strcmp(curseur->op,"move") == 0)
		printf("%s %s %s\n",curseur->op, curseur->res->name,curseur->arg1->name);

		else
		
		printf("%s %s %s %s\n",curseur->res->name,curseur->arg1->name, curseur->op, curseur->arg2->name);
		curseur = curseur->next;
		i++;
	}
}
