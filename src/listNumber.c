#include "listNumber.h"

//Add a linked int (number) at the end of the linked list
struct listNumber* addNumber(struct listNumber* list, int num)
{
	//Create the new linked int
	struct number* newNum = malloc(sizeof(struct number));
	newNum->value = num;
	newNum->next = NULL;

	//If the list is empty, simply add it
	if(list->begin == NULL)
	{
		list->begin = newNum;
		list->end = newNum;
		list->size = 1;
		return list;
	}

	//Add the linked int at the end of the list
	list->end->next = newNum;
	list->end = newNum;
	list->size++;
	return list;
}

//Concatenate 2 list of linked integer
struct listNumber* concatListNumber(struct listNumber* l1, struct listNumber* l2)
{
	l1->end->next = l2->begin;
	l1->end = l2->end;
	l1->size = l1->size + l2->size;

	return l1;
}

//Convert a linked list of int into an integer array (int*)
int* translateListToTab(struct listNumber* list,int* array)
{
	if(list->begin == NULL)
	{
		printf("WARNING : An empty linked list of number has been flushed in an empty array ! \n");
		return array;
	}

	//Flush the linked list in the array
	struct number* curseur = list->begin;
	int i=0;
	while(curseur != NULL)
	{
		array[i] = curseur->value;
		curseur = curseur->next;
		i++;
	}

	return array;
}
