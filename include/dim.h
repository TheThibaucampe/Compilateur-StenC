#ifndef __DIM_H__
#define __DIM_H__

//Linked dim
struct dim {
	int size;
	struct dim* next;
};

#include "tds.h"

void add_dim(struct symbol*, int);
int dim_size(struct symbol*, char*, int);
struct dim* appendToListDim(struct dim*, int);
int checkDims(struct dim*, struct dim*);
int checkDimsStencil(struct dim*, int, int) ;

#endif