#include "tds.h"

struct symbol* newtemp(struct symbol** tds)
{
	static int nb_temp = 0;
	char* nom=malloc(MAX_TAILLE_TEMP*sizeof(char));
	snprintf(nom, MAX_TAILLE_TEMP, "temp_%d",nb_temp);
	struct symbol* newTemp = add_temp_label(tds, nom,true);
	nb_temp++;
	return newTemp;
}


struct symbol* newLabel(struct symbol** tds, int valeur)
{
	struct symbol* newlabel;
	if((newlabel = lookup_label(*tds,valeur)) == NULL)
	{
		static int nb_label = 0;
		char* nom=malloc(MAX_TAILLE_TEMP*sizeof(char));
		snprintf(nom, MAX_TAILLE_TEMP, "label_%d",nb_label);
		newlabel = add_temp_label(tds, nom,true);
		newlabel->valeur = valeur;
		newlabel->label = 1;
		nb_label++;
	}
	return newlabel;
}


struct symbol* add_temp_label(struct symbol** tds, char* nom, int cst)
{
	struct symbol* newSymbol = malloc(sizeof(struct symbol));
	newSymbol->nom = strdup(nom);
	newSymbol->constante = cst;
	newSymbol->label = 0;
	newSymbol->is_string = 0;
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


struct symbol* add(struct symbol** tds, char* nom, int cst)
{
	struct symbol* newSymbol = malloc(sizeof(struct symbol));
	newSymbol->nom = malloc(MAX_TAILLE_TEMP*sizeof(char));
	snprintf(newSymbol->nom,MAX_TAILLE_TEMP,"A%s",nom);
	newSymbol->constante = cst;
	newSymbol->label = 0;
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
	char* tmp = malloc(MAX_TAILLE_TEMP*sizeof(char));
	snprintf(tmp,MAX_TAILLE_TEMP,"A%s",nom);

	struct symbol* curseur = tds;
	while(curseur != NULL)
	{
		if(strcmp(tmp,curseur->nom) == 0)
		{
			return curseur;
		}
		curseur = curseur->suivant;
	}

	free(tmp);
	return NULL;
}


struct symbol* lookup_tab(struct symbol* tds, char* nom)
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


struct symbol* lookup_label(struct symbol* tds, int numInstr)
{
	struct symbol* curseur = tds;
	while(curseur != NULL)
	{
		if(curseur->label == 1 && curseur->valeur == numInstr)
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
		if(curseur->is_string)
			printf("%s %d %s\n",curseur->nom,curseur->constante,curseur->string);
		else
			printf("%s %d %d\n",curseur->nom,curseur->constante,curseur->valeur);
		curseur = curseur->suivant;
	}
}
