struct coord* addCoord(struct coord* coord, struct symbol* val)
{
	struct coord* tmp = malloc(sizeof(struct coord));
	tmp->index = val;

	struct coord* curseur = coord;

	if(coord == NULL)
	{
		return tmp;
	}

	while(coord->suivant != NULL)
	{
		curseur = curseur->suivant;
	}

	curseur->suivant = tmp;

	return coord;
}
