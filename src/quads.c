#include "quads.h"

struct quads* quadsGen(char* op, struct symbol* arg1, struct symbol* arg2, struct symbol* res)
{
	struct quads* new_quads = malloc(sizeof(struct quads));
	new_quads->op = strdup(op);
	new_quads->arg1 = arg1;
	new_quads->arg2 = arg2;
	new_quads->res = res;
	new_quads->suivant = NULL;

	nextquad++;

	return new_quads;
}


struct quads* quadsConcat(struct quads* quads1, struct quads* quads2, struct quads* quads3)
{
	struct quads* curseur = quads1;
	struct quads* retour = quads1;

	if(quads1 != NULL)
	{
		while(curseur->suivant != NULL)
		{
			curseur = curseur->suivant;
		}
		curseur->suivant = quads2;
	}
	else
	{
		retour = quads2;
	}

	if(quads2 != NULL)
	{
		curseur = quads2;
		while(curseur->suivant != NULL)
		{
			curseur = curseur->suivant;
		}

		curseur->suivant = quads3;
	}
	else if(quads2 == NULL && NULL == quads1)
	{
		retour = quads3;
	}
	else
	{
		curseur->suivant = quads3;
	}

	return retour;
}



void quadsPrint(struct quads* quads)
{
	struct quads* curseur = quads;

	while(curseur != NULL)
	{
		if(strcmp(curseur->op,"goto") == 0)
		printf("%s %s\n",curseur->op,curseur->res->nom);

		else if(strcmp(curseur->op,"move") == 0)
		printf("%s %s %s\n",curseur->op, curseur->res->nom,curseur->arg1->nom);

		else
		
		printf("%s %s %s %s\n",curseur->res->nom,curseur->arg1->nom, curseur->op, curseur->arg2->nom);
		curseur = curseur->suivant;
	}
}
