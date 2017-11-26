#include "tradCode.h"

void tradCodeFinal(char* outputFileName, struct quads* quads,struct symbol* tds)
{
	FILE* outputFile = fopen(outputFileName,"w");

	fprintf(outputFile,".data\n\n");

	struct symbol* curseur_tds = tds;

	while(curseur_tds != NULL)
	{
		if(curseur_tds->label == 1)
		{
			fprintf(outputFile,".label %s\n",curseur_tds->nom);
		}
		else
		{
			fprintf(outputFile,".word %s %d\n",curseur_tds->nom,curseur_tds->valeur);
		}

		curseur_tds = curseur_tds->suivant;
	}
	



/***********************text*************************/

	fprintf(outputFile,"\n.text\n\n");

	struct quads* curseur_quads = quads;
	struct symbol* label;
	int instr_cmpt = 1;


	while(curseur_quads != NULL)
	{
		if((label = lookup_label(tds,instr_cmpt)) != NULL)
		{
			fprintf(outputFile,"%s:\n",label->nom);
		}


		if(strcmp(curseur_quads->op,"j") == 0)
		{
			fprintf(outputFile,"%s %s\n",curseur_quads->op,curseur_quads->res->nom);
		}

		else if(strcmp(curseur_quads->op,"move") == 0)
		{
			fprintf(outputFile,"%s %s %s\n",curseur_quads->op, curseur_quads->res->nom,curseur_quads->arg1->nom);
		}

		else if(strcmp(curseur_quads->op,"beq") == 0 ||strcmp(curseur_quads->op,"bne") == 0 ||strcmp(curseur_quads->op,"ble") == 0 ||strcmp(curseur_quads->op,"blt") == 0 ||strcmp(curseur_quads->op,"bge") == 0 ||strcmp(curseur_quads->op,"bgt") == 0)
		{
		
			fprintf(outputFile,"%s %s %s %s\n",curseur_quads->op,curseur_quads->arg1->nom, curseur_quads->arg2->nom,curseur_quads->res->nom);
		}

		else
		{
			fprintf(outputFile,"%s %s %s %s\n",curseur_quads->op,curseur_quads->res->nom, curseur_quads->arg1->nom, curseur_quads->arg2->nom);
		}

		curseur_quads = curseur_quads->suivant;

		instr_cmpt++;

	}

	fclose(outputFile);
}
