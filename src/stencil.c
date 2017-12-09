#include "stencil.h"

int total_element(int rayon, int dim)
{
	return (int) pow((2*rayon+1), dim);
}

int decalage(struct dim* dims, int rayon, int nb_dim, int r);
{
	int current_dim = nb_dim - 1;
	int tmp = r;
	int result = (tmp / total_element(rayon, current_dim)) - rayon;
	struct dim* curseur = dims->suivant;
	while (current_dim > 0)
	{
		result *= curseur->size;
		tmp %= total_element(rayon, current_dim);
		result += ((tmp / total_element(rayon, current_dim)) - rayon);

		current_dim--;
		curseur = curseur->suivant; 
	}

	result *= -1;
	return result;
}