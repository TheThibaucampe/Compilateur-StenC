#ifndef __TDS_H__
#define __TDS_H__

#define false 0
#define true 1
//A name can have up to 64 characters
#define MAX_TAILLE_TEMP 64
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "enum.h"

struct symbol{
	char* name;
	int is_constant;
	int is_array;
	int type;
	union {
		int value;
		char* string;
		struct {
			struct dim* size_dim;
			int length;
			int* array_value;
		};
		struct {
      struct dim* size_dim_stenc;
      int length_stenc;
      int* value_tab_stenc;
      int radius;
      int nb_dim;
		};
	};
	struct symbol* next;
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