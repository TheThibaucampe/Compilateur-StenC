#include "tds.h"

//Create a new temporary
struct symbol* newtemp(struct symbol** tds)
{
	//Prepare the properties of the temporary
	static int nb_temp = 0;
	char* name=malloc(MAX_TAILLE_TEMP*sizeof(char));
	snprintf(name, MAX_TAILLE_TEMP, "temp_%d",nb_temp);

	//Send the properties and get the symbol of the temporary
	struct symbol* newTemp = add_temp_label(tds, name,true);
	nb_temp++;
	return newTemp;
}

//Create a new label
struct symbol* newLabel(struct symbol** tds, int value)
{
	struct symbol* newlabel;
	//Check if the label does not already exists
	if((newlabel = lookup_label(*tds,value)) == NULL)
	{
		//Prepare the properties
		static int nb_label = 0;
		char* name=malloc(MAX_TAILLE_TEMP*sizeof(char));
		snprintf(name, MAX_TAILLE_TEMP, "label_%d",nb_label);

		//Send the properties and get the symbol of the label
		newlabel = add_temp_label(tds, name,true);

		//Add more properties
		newlabel->value = value;
		newlabel->type = LABEL_TYPE;
		nb_label++;
	}
	return newlabel;
}

//Create the symbol of a temporary and add it to the table of symbols
struct symbol* add_temp_label(struct symbol** tds, char* name, int cst)
{
	//Create the symbol
	struct symbol* newSymbol = malloc(sizeof(struct symbol));
	newSymbol->name = strdup(name);
	newSymbol->is_constant = cst;
	newSymbol->type = LABEL_TYPE;
	newSymbol->next = NULL;

	//If the table is empty
	if(*tds == NULL)
	{
		//Simply add it to the table
		*tds = newSymbol;
		return newSymbol;
	}

	//Go at the end of the table
	struct symbol* curseur = *tds;
	while(curseur->next != NULL)
	{
		curseur = curseur->next;
	}
	//Add the new symbol
	curseur->next = newSymbol;

	return newSymbol;
}

//Create the symbol of a label and add it to the table of symbols
struct symbol* add(struct symbol** tds, char* name, int cst)
{
	//Create the symbol
	struct symbol* newSymbol = malloc(sizeof(struct symbol));
	newSymbol->name = malloc(MAX_TAILLE_TEMP*sizeof(char));
	snprintf(newSymbol->name,MAX_TAILLE_TEMP,"A%s",name);
	newSymbol->is_constant = cst;
	newSymbol->next = NULL;

	//If the table is empty
	if(*tds == NULL)
	{
		//Simply add it to the table
		*tds = newSymbol;
		return newSymbol;
	}

	//Go at the end of the table
	struct symbol* curseur = *tds;
	while(curseur->next != NULL)
	{
		curseur = curseur->next;
	}
	//Add the new symbol
	curseur->next = newSymbol;

	return newSymbol;
}

//Get back a symbol from its name
struct symbol* lookup(struct symbol* tds, char* name)
{
	//Create the good name
	char* tmp = malloc(MAX_TAILLE_TEMP*sizeof(char));
	snprintf(tmp,MAX_TAILLE_TEMP,"A%s",name);

	//Go through the table
	struct symbol* curseur = tds;
	while(curseur != NULL)
	{
		if(strcmp(tmp,curseur->name) == 0)
		{
			return curseur;
		}
		curseur = curseur->next;
	}

	free(tmp);
	return NULL;
}

//Get back a symbol from its name
struct symbol* lookup_tab(struct symbol* tds, char* name)
{
	struct symbol* curseur = tds;
	while(curseur != NULL)
	{
		if(strcmp(name,curseur->name) == 0)
		{
			return curseur;
		}
		curseur = curseur->next;
	}

	return NULL;
}

//Get back a symbol from its name
struct symbol* lookup_label(struct symbol* tds, int numInstr)
{
	struct symbol* curseur = tds;
	while(curseur != NULL)
	{
		if(curseur->type == LABEL_TYPE && curseur->value == numInstr)
		{
			return curseur;
		}
		curseur = curseur->next;
	}

	return NULL;
}

//Print all the table of symbol
void print(struct symbol* tds)
{
	struct symbol* curseur = tds;
	while(curseur != NULL)
	{
		if(curseur->type == STRING_TYPE)
			printf("%s %d %s\n",curseur->name,curseur->is_constant,curseur->string);
		else
			printf("%s %d %d\n",curseur->name,curseur->is_constant,curseur->value);
		curseur = curseur->next;
	}
}
