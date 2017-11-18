#include "tds.h"

struct symbol* newtemp(struct symbol** tds)
{
	static int nb_temp = 0;
	char* nom=malloc(MAX_TAILLE_TEMP*sizeof(char));
	snprintf(nom, MAX_TAILLE_TEMP, "temp_%d",nb_temp);
	struct symbol* newTemp = add(tds, nom,true);
	nb_temp++;
	return newTemp;
}


struct symbol* add(struct symbol** tds, char* nom, int cst)
{
	struct symbol* newSymbol = malloc(sizeof(struct symbol));
	newSymbol->nom = strdup(nom);
	newSymbol->constante = cst;
	newSymbol->suivant = NULL;

	if(*tds == NULL)
	{
		*tds = newSymbol;
		return newSymbol;
	}

	struct symbol* curseur = *tds;
	while(curseur->suivant != NULL)
	{
		curseur = curseur->suivant;
	}

	curseur->suivant = newSymbol;

	return newSymbol;
}


struct symbol* lookup(struct symbol* tds, char* nom)
{
	struct symbol* curseur = tds;
	while(curseur != NULL)
	{
		if(strcmp(nom,curseur->nom) == 0)
		{
			return curseur;
		}
		curseur = curseur->suivant;
	}

	return NULL;
}


void print(struct symbol* tds)
{
	struct symbol* curseur = tds;
	while(curseur != NULL)
	{
		printf("%s %d %d\n",curseur->nom,curseur->constante,curseur->valeur);
		curseur = curseur->suivant;
	}
}
