#ifndef __COORD_H__
#define __COORD_H__

#include "tds.h"


struct coord {
	struct symbol* index;
	struct coord* suivant;
};


struct coord* addCoord(struct coord*, struct symbol*);


#endif
