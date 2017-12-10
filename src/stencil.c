#include "stencil.h"

//Compute the number of element in an array defined by its radius and its dimension
int total_element(int radius, int dim)
{
	return (int) pow((2*radius+1), dim);
}

/* Compute a shift in a multidimensional array as an linear array 
 * This function will be used to compute the address of an element of an multidimentional array from a basis element
 * More specificaly, it wille be used for the stencil operation
 * It has been built from the formula of access in the Dragon Book, and has been modified as a formula of Horner
 *
 *
 */
int decalage(struct dim* dims, int radius, int nb_dim, int r)
{
	int current_dim = nb_dim - 1;
	int tmp = r;
	int result = (tmp / total_element(radius, current_dim)) - radius;
	struct dim* curseur = dims->next;
	while (current_dim > 0)
	{
		result *= curseur->size;
    	tmp %= total_element(radius, current_dim);
    	current_dim--;

		if(current_dim == 0)
		{
			result +=(tmp - radius);	
		} else
		{
			result += ((tmp / total_element(radius, current_dim)) - radius);
		}
    	curseur = curseur->next;
	}
	return result;
}
