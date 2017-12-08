#include "listNumber.h"



struct listNumber* addNumber(struct listNumber* list, int num)
{
	struct number* newNum = malloc(sizeof(struct number));
	newNum->number = num;
	newNum->suivant = NULL;

	if(list->debut == NULL)
	{
		list->debut = newNum;
		list->fin = newNum;
		list->taille = 1;
		return list;
	}

	list->fin->suivant = newNum;
	list->fin = newNum;
	list->taille++;
	return list;
}


struct listNumber* concatListNumber(struct listNumber* l1, struct listNumber* l2)
{
	l1->fin->suivant = l2->debut;
	l1->fin = l2->fin;
	l1->taille = l1->taille + l2->taille;

	return l1;
}


int* translateListToTab(struct listNumber* list)
{
	int* tab = malloc(list->taille*sizeof(int));

	if(list->debut == NULL)
	{
		//TODO que faire si la liste est vide (tableau initialisé avec rien)
		return tab;
	}

	struct number* curseur = list->debut;
	int i=0;

	while(curseur != NULL)
	{
		tab[i] = curseur->number;

		curseur = curseur->suivant;
		i++;
	}

	return tab;
}
