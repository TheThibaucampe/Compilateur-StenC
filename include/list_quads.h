#ifndef __LIST_QUADS__
#define __LIST_QUADS__

#include "quads.h"

//Structure for falselists and truelists
struct list_quads {
	struct quads* quads;
	struct list_quads* next;
};

struct list_quads* new_list_quads(struct quads*);
struct list_quads* concat_list_quads(struct list_quads*, struct list_quads*);
struct list_quads* complete_list_quads(struct list_quads*, struct symbol*);

#endif