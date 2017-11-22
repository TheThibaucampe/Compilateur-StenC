#ifndef __QUADLIST_H__
#define __QUADLIST_H__

#include "quads.h"
#include <stdio.h>
#include <stdlib.h>

struct quadlist {
	struct quads* ptr;
	struct quadlist* GOTO; //Pointeur vers un quadlist (de truelist ou falselist)
	struct quadlist* nextlist;
};
typedef struct quadlist quadlist;

quadlist* newlist(struct quads*);
quadlist* concat(quadlist*, quadlist*);
void complete(quadlist*, quadlist*);
//Void print(quadlist*);


#endif
