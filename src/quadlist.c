#include "quadlist.h"

struct quadlist* newlist(struct quads* q)
{
	struct quadlist* newquadlist = (struct quadlist*) malloc(sizeof(struct quadlist));
	newquadlist->ptr = q;
	newquadlist->GOTO = 0;
	newquadlist->nextlist = NULL;

	return newquadlist;
}

struct quadlist* concat(struct quadlist* q1, struct quadlist* q2)
{
	struct quadlist* ptr = q1;
	while (ptr->nextlist != NULL) {ptr = ptr->nextlist;}
	q1->nextlist = q2;
	return q1;
}

void complete(struct quadlist* ql, struct quads* label)
{
	struct quadlist* ptr = ql;
	while (ptr->nextlist != NULL)
	{
		//Tous GOTO de truelist et falselist ont un GOTO vide
		ptr->GOTO = label;
		ptr = ptr->nextlist;  
	}
	ptr->GOTO = label;
}