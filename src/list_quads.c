#include "list_quads.h"

//Create a new list_quads structure from a given quad
struct list_quads* new_list_quads(struct quads* quads)
{
	//Create the list_quad
	struct list_quads* newList = malloc(sizeof(struct list_quads));
	newList->quads = quads;
	newList->next = NULL;

	return newList;
}

//Concatenate 2 list-quads
struct list_quads* concat_list_quads(struct list_quads* l1, struct list_quads* l2)
{
	if(l1 != NULL)
	{
		struct list_quads* curseur = l1;
		while(curseur->next != NULL)
		{
			curseur = curseur->next;
		}
		curseur->next = l2;
		return l1;
	}
	else //If l1 is empty, simply return l2
	{
		return l2;
	}
}

//Complete the list_quad with a given symbol
//This function will be used to complete falselists and truelists with the right gotos
struct list_quads* complete_list_quads(struct list_quads* list_quads, struct symbol* s)
{
	if(list_quads == NULL)
	{
		printf("Erreur complete list quads, list quads void\n");
		return NULL;
	}

	struct list_quads* curseur = list_quads;
	while(curseur != NULL)
	{
		//Completion
		curseur->quads->res = s;
		curseur = curseur->next;
	}

	return list_quads;	
}
