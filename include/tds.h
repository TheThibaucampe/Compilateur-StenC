#ifndef __TDS_H__
#define __TDS_H__

#define false 0
#define true 1
#define MAX_TAILLE_TEMP 10
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

struct symbol{
	char* nom;
	int constante;
	int label;
	int valeur;
	struct symbol* suivant;
};


struct symbol* newtemp(struct symbol**);
struct symbol* newLabel(struct symbol**, int);
struct symbol* add(struct symbol**, char*, int);
struct symbol* lookup(struct symbol*, char*);
struct symbol* lookup_label(struct symbol*, int);
void print(struct symbol*);


#endif
