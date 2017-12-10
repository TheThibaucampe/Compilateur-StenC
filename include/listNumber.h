#ifndef __LISTNUMBER_H__
#define __LISTNUMBER_H__

#include <stdio.h>
#include <stdlib.h>

//Linked integer (called number)
struct number {
	int value;
	struct number* next;
};

//List of linked integer
struct listNumber {
	struct number* begin;
	struct number* end;
	int size;
};

struct listNumber* addNumber(struct listNumber*, int);
int* translateListToTab(struct listNumber*,int*);
struct listNumber* concatListNumber(struct listNumber*, struct listNumber*);

#endif
