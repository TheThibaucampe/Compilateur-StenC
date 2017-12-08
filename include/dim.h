#ifndef __DIM_H__
#define __DIM_H__


struct dim {
	int size;
	struct dim* suivant;
};


#include "tds.h"

void add_dim(struct symbol*, int);
int dim_size(struct symbol*, char*, int);
struct dim* appendToListDim(struct dim*, int);
int checkDims(struct dim*, struct dim*);
int checkDimsStencil(struct dim*,int, int) ;

#endif
