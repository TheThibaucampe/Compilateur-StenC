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
	int is_string;
	int is_array;
	union {
		int valeur;
		char* string;
		struct {
			struct dim* taille_dim;
			int length;
			int* valeur_tab;
		};
	};
	struct symbol* suivant;
};

#include "dim.h"

struct symbol* newtemp(struct symbol**);
struct symbol* newLabel(struct symbol**, int);
struct symbol* add(struct symbol**, char*, int);
struct symbol* add_temp_label(struct symbol**, char*, int);
struct symbol* lookup(struct symbol*, char*);
struct symbol* lookup_label(struct symbol*, int);
struct symbol* lookup_tab(struct symbol*, char*);
void print(struct symbol*);


#endif
