int main() {
	int i, j;
	int gx, gy;
	int image[HEIGHT][WIDTH]; // Image originale en niveaux de gris.
	int sobel[HEIGHT][WIDTH]; // Image transformée.

	stencil gx {1,2} = {{ 1, 0,-1},{ 2, 0,-2},{ 1, 0,-1}};
  
  // Filtre Sobel
	for (i = 1; i < HEIGHT - 1; i++)
	{
		for (j = 1; j < WIDTH - 1; j++)
		{
    	sobel[i][j] = gx $ image[i][j];
		}
	}
	return 0;
}
