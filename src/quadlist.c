#include "quadlist.h"

quadlist* newlist(struct quads* q)
{
	quadlist* newquadlist = (quadlist*) malloc(sizeof(quadlist));
	newquadlist->ptr = q;
	newquadlist->GOTO = 0;
	newquadlist->nextlist = NULL;

	return newquadlist;
}

quadlist* concat(quadlist* q1, quadlist* q2)
{
	//Concaténation
	q1->nextlist = q2;
	return q1;
}

void complete(quadlist* ql, quadlist* label)
{
	quadlist* ptr = ql;
	while (ptr->nextlist == NULL)
	{
		//Tous GOTO de truelist et falselist ont un GOTO vide
		ptr->GOTO = label;
		ptr = ptr->nextlist;  
	}
	ptr->GOTO = label;
}

void print(quadlist* ql)
{

}