#ifndef __LISTNUMBER_H__
#define __LISTNUMBER_H__


#include <stdio.h>
#include <stdlib.h>

struct number {
	int number;
	struct number* suivant;
};


struct listNumber {
	struct number* debut;
	struct number* fin;
	int taille;
};


struct listNumber* addNumber(struct listNumber*, int);
int* translateListToTab(struct listNumber*);
struct listNumber* concatListNumber(struct listNumber*, struct listNumber*);


#endif
