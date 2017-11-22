#ifndef __QUADLIST_H__
#define __QUADLIST_H__

#include "quads.h"
#include <stdio.h>
#include <stdlib.h>

struct quadlist {
	struct quads* ptr;
	struct quads* GOTO;
	struct quadlist* nextlist;
};

struct quadlist* newlist(struct quads*);
struct quadlist* concat(struct quadlist*, struct quadlist*);
void complete(struct quadlist*, struct quads*);
//Void print(quadlist*);


#endif
