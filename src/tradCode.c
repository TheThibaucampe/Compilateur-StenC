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


		if(strcmp(curseur->op,"j") == 0)
		fprintf(outputFile,"%s %s\n",curseur->op,curseur->res->nom);

		else if(strcmp(curseur->op,"move") == 0)
		fprintf(outputFile,"%s %s %s\n",curseur->op, curseur->res->nom,curseur->arg1->nom);

		else if(strcmp(curseur->op,"beq") == 0 ||strcmp(curseur->op,"bne") == 0 ||strcmp(curseur->op,"ble") == 0 ||strcmp(curseur->op,"blt") == 0 ||strcmp(curseur->op,"bge") == 0 ||strcmp(curseur->op,"bgt") == 0)
		
		fprintf(outputFile,"%s %s %s %s\n",curseur->op,curseur->arg1->nom, curseur->arg2->nom,curseur->res->nom);

		else
		
		fprintf(outputFile,"%s %s %s %s\n",curseur->op,curseur->res->nom, curseur->arg1->nom, curseur->arg2->nom);
		curseur = curseur->suivant;

		instr_cmpt++;

	}

	fclose(outputFile);
}
