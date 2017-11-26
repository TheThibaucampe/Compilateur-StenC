#include "tradCode.h"

void tradCodeFinal(char* outputFileName, struct quads* quads,struct symbol* tds)
{
	FILE* outputFile = fopen(outputFileName,"w");

	struct quads* curseur = quads;
	struct symbol* label;
	int instr_cmpt = 1;

	while(curseur != NULL)
	{
		if((label = lookup_label(tds,instr_cmpt)) != NULL)
		{
			fprintf(outputFile,"%s:\n",label->nom);
		}


		if(strcmp(curseur->op,"goto") == 0)
		fprintf(outputFile,"%s %s\n",curseur->op,curseur->res->nom);

		else if(strcmp(curseur->op,"move") == 0)
		fprintf(outputFile,"%s %s %s\n",curseur->op, curseur->res->nom,curseur->arg1->nom);

		else
		
		fprintf(outputFile,"%s %s %s %s\n",curseur->res->nom,curseur->arg1->nom, curseur->op, curseur->arg2->nom);
		curseur = curseur->suivant;

		instr_cmpt++;

	}

	fclose(outputFile);
}
