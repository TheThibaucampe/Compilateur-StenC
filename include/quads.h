#ifndef __QUADS_H__
#define __QUADS_H__

#include "tds.h"
#include <stdio.h>
#include <stdlib.h>

extern int nextquad;

struct quads {
	char* op;
	struct symbol* arg1;
	struct symbol* arg2;
	struct symbol* res;
	struct quads* suivant;
};

struct quads* quadsGen(char* , struct symbol*,struct symbol*, struct symbol*);
struct quads* quadsConcat(struct quads*, struct quads*, struct quads*);
void quadsPrint(struct quads*);


#endif
