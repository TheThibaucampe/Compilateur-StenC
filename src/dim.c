#include "dim.h"

//Add a new dimension at athe end of the list
void add_dim(struct symbol* array, int size)
{
	struct dim* list_dim = array->size_dim;

	//Create the new linked dimension
	struct dim* newDim = malloc(sizeof(struct dim));
	newDim->size = size;
	newDim->next = NULL;

	//If the list is empty
	if(list_dim == NULL)
	{
		//Simply add it to the ring
		array->size_dim = newDim;
		return;
	}

	//Go though the list
	while(list_dim->next != NULL)
	{
		list_dim = list_dim->next;
	}
	//Add it at the end of the list
	list_dim->next = newDim;
}

//Add a new dimension at the beginning of a list
struct dim* appendToListDim(struct dim* dim, int size)
{
	//Create the new dimension
	struct dim* tmp = malloc(sizeof(struct dim));
	tmp->size = size;

	//Add it at the beginning of the list
	tmp->next = dim;

	return tmp;
}

//Return the size of a given dimension
int dim_size(struct symbol* tds, char* name, int dim)
{
	//Get back the symbol of the array
	struct symbol* array = lookup_tab(tds,name);
	if(array == NULL)
	{
		printf("Erreur, %s n'est pas déclaré\n",name);
		exit(-1);
	}
	if(array->is_array == false)
	{
		printf("Erreur, %s n'est pas un tableau\n",name);
		exit(-1);
	}

	//Go through the list to find the right dimension
	struct dim* list_dim = array->size_dim;
	int tmp = 1;
	while(list_dim != NULL)
	{
		if(tmp == dim)
		{
			//The right dimension is found
			return list_dim->size;
		}
		tmp++;
		list_dim = list_dim->next;
	}

	printf("Erreur, %s n'a pas de %d i-eme dimension\n",name,dim);
	exit(-1);
}

//Check if 2 lists of dimensions are equal
int checkDims(struct dim* d1, struct dim* d2)
{
	struct dim* curseur1 = d1;
	struct dim* curseur2 = d2;

	//Go through the lists
	while(curseur1 != NULL && curseur2 != NULL)
	{
		//Check if the sizes of the dimensions are equal
		if(curseur1->size != curseur2->size)
		{
			printf("Erreur de largeur : L1 = %d, L2 = %d\n", curseur1->size, curseur2->size);
			exit(-1);
		}
		curseur1 = curseur1->next;
		curseur2 = curseur2->next;
	}

	//Check if the length of the lists are the same
	if(curseur1 != curseur2)
	{
		printf("Erreur dimension\n");
		exit(-1);
	}

	return 1;
}

//Check if a list of dimensions matches the properties of a stencil
int checkDimsStencil(struct dim* list_dim, int radius, int nb_dim)
{
	//Go through the list
	struct dim* curseur = list_dim->next;
	int count = 0;
	while (curseur != NULL && count <= nb_dim)
	{
		//Check radius condition
		if (curseur->size != 2*radius+1)
		{
			printf("Condition de rayon non respectée\n");
			exit(-1);
		}
		count++;
		curseur = curseur->next;
	}

	//Check the dimension condition
	if (count != nb_dim)
	{
		printf("Mauvaise dimension attendue\n");
		exit(-1);
	}
	return 1;
}