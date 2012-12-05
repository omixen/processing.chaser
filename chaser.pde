
i = 0;
g_grid = 10;

void setup()
{
	size(801, 801);
    background(255);
    frameRate(24);

    g_grid = new Grid(100, 100, 800, 800);
}

void draw()
{
	g_grid.draw();
}

void mousePressed()
{

}
void mouseReleased()
{
	
}


void h_manhattan()
{

}

class Grid
{
	int[][] grid;
	float width, height, stepX, stepY, countX, countY;
	Grid(int cX, int cY, float wX, float wY)
	{
		countX = cX;
		countY = cY;
		width = wX;
		height = wY;
		stepX = wX/cX;
		stepY = wY/cY;
		//create grid
		grid = new int[countX][countY];
	}
	void draw()
	{
		stroke(200, 200, 200, 100);
		strokeWeight(1);
		smooth();
		line(0, 0, width, 0);
		line(width, 0, width, height);
		line(width, height, 0, height);
		line(0, height, 0, 0);

		//x
		float temp = 0;
		for(i=0;i<countX;i++)
		{
			temp = i*stepX;
			line(temp, 0, temp, height);
		}
		//y
		for(i=0;i<countY;i++)
		{
			temp = i*stepY;
			line(0, temp, width, temp);
		}
	}
}