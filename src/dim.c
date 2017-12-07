#include "dim.h"

void add_dim(struct symbol* tab, int taille)
{
	struct dim* list_dim = tab->taille_dim;

	struct dim* newDim = malloc(sizeof(struct dim));

	newDim->size = taille;
	newDim->suivant = NULL;


	if(list_dim == NULL)
	{
		tab->taille_dim = newDim;
		return;
	}

	while(list_dim->suivant != NULL)
	{
		list_dim = list_dim->suivant;
	}

	
	list_dim->suivant = newDim;
	
}

int dim_size(struct symbol* tds, char* tab_name, int dim)
{
	struct symbol* tab = lookup_tab(tds,tab_name);
	if(tab->is_array == 0)
	{
		printf("Erreur, %s n'est pas un tableau\n",tab_name);
		exit(-1);
	}
	struct dim* list_dim = tab->taille_dim;

	int tmp = 1;

	while(list_dim != NULL)
	{
		if(tmp == dim)
		{
			return list_dim->size;
		}

		tmp++;
		list_dim = list_dim->suivant;
	}

	printf("Erreur, %s n'a pas de %d i-eme dimension\n",tab_name,dim);
	exit(-1);
}
