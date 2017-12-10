#include "util.h"

extern struct symbol* tds;
extern struct quads* code;

void print_error(int type, char* message)
{
	switch(type)
	{
		//TODO
		default:
			return;
	}
}

void free_tds(struct symbol* tds)
{
	struct symbol* current_symbol = tds;
	struct symbol* Bfree_symbol= current_symbol;
	while (current != NULL)
	{
		free(current_symbol->name);
		if (current_symbol->is_array)
		{
			if (current_symbol->type == STENCIL_TYPE)
			{
				struct dim* current_dim = current_symbol->size_dim_stenc;
				struct dim* Bfree_dim = current_dim;
				while (current_dim != NULL)
				{
					current_dim = current_dim->next;
					free(Bfre_dim);
					Bfree_dim = current_dim;
				}
				free(current_symbol->value_tab_stenc);
				break;
			} else
			{
				struct dim* current_dim = current_symbol->size_dim;
				struct dim* Bfree_dim = current_dim;
				while (current_dim != NULL)
				{
					current_dim = current_dim->next;
					free(Bfree_dim);
					Bfree_dim = current_dim;
				}
				free(current_symbol->array_value);
			}
		} else
		{
			if (current_symbol->type == STRING_TYPE)
			{
				free(current_symbol->string);
			}
		}

		current_symbol = current_symbol->next;
		free(Bfree_symbol);
		Bfree_symbol = current_symbol;
	}
	return;
}

void free_code(struct quads* quad)
{
	struct quads* current = quad;
	struct quads* Bfree = current;
	while (current != NULL)
	{
		free(current->op);
		//Args of quad are freeing during the freeing of the table of symbols
		current = current->next;
		free(Bfree);
		Bfree = current;
	}
	return;
}

void free_list_quad(struct list_quads* lq);
{
	struct list_quads* current = lq;
	struct list_quads* Bfree = current;
	while (current != NULL)
	{
		//quads are freeing during the freeing of the code
		current = current->next;
		free(Bfree);
		Bfree = current;
	}
	return;
}

void free_listNumber(struct listNumber* lN);
{
	struct listNumber* current = lN->begin;
	struct listNumber* Bfree = current;
	while (current != NULL)
	{
		current = current->next;
		free(Bfree);
		Bfree = current;
	}
	free(lN);
	return;
}

void free_all()
{
	free_code(code);
	free_tds(tds);
}