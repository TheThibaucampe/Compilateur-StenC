#include "list_quads.h"


struct list_quads* new_list_quads(struct quads* quads)
{
	struct list_quads* newList = malloc(sizeof(struct list_quads));
	newList->quads = quads;
	newList->suivant = NULL;

	return newList;
}



struct list_quads* concat_list_quads(struct list_quads* l1, struct list_quads* l2)
{
	if(l1 != NULL)
	{
		struct list_quads* curseur = l1;

		while(curseur->suivant != NULL)
		{
			curseur = curseur->suivant;
		}

		curseur->suivant = l2;

		return l1;
	}
	else
	{
		return l2;
	}
}



struct list_quads* complete_list_quads(struct list_quads* list_quads, struct symbol* s)
{
	if(list_quads == NULL)
	{
		printf("Erreur complete list quads, list quads void\n");
		return NULL;
	}

	struct list_quads*  curseur = list_quads;

	while(curseur != NULL)
	{
		curseur->quads->res = s;
		curseur = curseur->suivant;
	}

	return list_quads;	
}
