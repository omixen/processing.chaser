
i = 0;
int MAXVELOCITY = 12;
Grid g_grid;
Chaser g_chaser;

void setup()
{
	size(801, 801);    
    frameRate(24);
    g_grid = new Grid(100, 100, 800, 800);
    g_chaser = new Chaser(color(132,47,68), g_grid, 1, 1, 8);
}

void draw()
{
	background(16,60,71,255);
	g_grid.draw();
	smooth();	
	//g_chaser.chase(new PVector(mouseX, mouseY));
	//g_chaser.draw();
	//fade(0, 10);
}

void fade( color fadeColor , int fadeLevel ) {
  noStroke(); fill(fadeColor, fadeLevel) ;
  rect(0,0, width,height) ;
}

//update target based on the mouse position
void mousePressed()
{

}
void mouseReleased()
{
	
}

//assuming equal cost for all 8
float h_manhattan(PVector current, PVector target)
{
	return (abs(current.x-target.x)+abs(current.y-target.y));
}
float h_diagonal(PVector current, PVector target)
{
	return max(abs(current.x-target.x), abs(current.y-target-y));
}
float h_euclidean(PVector current, PVector target)
{
	return sqrt(sq(current.x-target.x)+sq(current.y-target.y));
} 

class Chaser
{
	color cMain;
	Grid gGrid;
	PVector vPosition;
	
	PVector vLocation;
	PVector vOldLocation;
	PVector vVelocity;
	float fSize;
	
	BinaryHeap hStack;
	ArrayList vPath;

	//heuristic type
	// 0. djikstra (no heuristic) 1. manhattan, 2.diagonal (default), 3.euclidean 
	int hType;

	Chaser(color cM, Grid gG, int pX, int pY, float sZ)
	{
		cMain = cM;
		gGrid = gG;
		vPosition = new PVector(pX, pY);
		vLocation = gGrid.getLocation(vPosition);
		vOldLocation = vLocation;
		vVelocity = new PVector(0, 0);
		fSize = sZ;
		hType = 2;
	}
	void draw()
	{		
		PVector loc = this.getLocation();
		ellipseMode(CENTER);
		fill(cMain);
		ellipse(loc.x, loc.y, fSize, fSize);
		stroke(random(255), random(255), random(255));
		line(vOldLocation.x, vOldLocation.y, loc.x, loc.y);
		vOldLocation = loc;
	}
	void chase(PVector target)
	{
		//vVelocity.limit(MAXVELOCITY);
    	PVector targetVector = PVector.sub(target, gGrid.getLocation(vPosition));  
    	vVelocity.add(targetVector);
    	vVelocity.mult(.5);
    	PVector loc = this.getLocation();		
		loc.add(vVelocity);
		vPosition = gGrid.getPosition(loc);
		updateLocation();
	}
	void findPath(PVector target)
	{
		start = vPosition;
		//vars to hold helper heap and resulting path
		hOpenStack =  new BinaryHeap();
		hStack.push(gGrid[start.x][start.y]);
		vPath = new ArrayList();
		//if we're already at the target, done.
		currentNode = hOpenStack.pop();
		//until we find the target or nothing else in our stack
		while(currentNode != null && currentNode.vPosition != target)
		{
			//vPath.add(currentNode);
			neighbors = gGrid.getNeighbors(currentNode.vPosition);
			currentNode.bClosed = true;
			for(p=0;p<neighbors.size();p++)
			{
				neighbor = PathNode(neighbors.get(p));		
				//no need to check if neighbor is an obstacle
				if(gGrid.isObstacle(neighbor.vPosition))
				{
					continue;
				}
				//calculate cost to neighbor
				cost = currentNode.gValue + gGrid[neighbor.x][neighbor.y];
				if(neighbor.bVisited && cost<neighbor.gValue)
				{
					neighbor.bVisited = false;
				}
				if(neighbor.bClosed && cost<neighbor.gValue)
				{
					neighbor.bClosed = false;
				}
				//
				if(!neighbor.bVisited && !neighbor.bClosed && cost<neighbor.gValue)
				{
					neighbor.bVisited = true;
					neighbor.gValue = cost;
					neighbor.hValue = h_diagonal(neighbor.vPosition, target);
					neighbor.fValue = neighbor.gValue + neighbor.hValue;
					neighbor.nParent = currentNode;
					//add to our stack
					hOpenStack.push(neighbor);
				}
			}
			//next
			currentNode = hStack.pop();
		}
		//calculate the path as reverse path from target
		targetNode = PathNode(grid[target.x][target.y]);
		vPath = targetNode.getReversePath();
	}	
	void runPath()
	{

	}
	void updateLocation()
	{
		vLocation = gGrid.getLocation(vPosition);
	}
	PVector getLocation()
	{
		return vLocation;
	}
}

class Grid
{
	PathNode[][] grid;
	PVector vCount, vSize, vStep;
	float left, top;

	Grid(int cX, int cY, float wX, float wY)
	{
		vCount = new PVector(cX, cY);
		vSize = new PVector(wX, wY);
		vStep = new PVector(wX/cX, wY/cY);
		left = vStep.x/2;
		top = vStep.y/2;
		//create grid
		grid = new PathNode[vCount.x][vCount.y];
		this.initGrid();
		alert(grid[int(random(100))][int(random(100))].fCost);
		this.generateObstacles(.2);
		alert(grid[int(random(100))][int(random(100))].fCost);
	}
	void draw()
	{
		stroke(45,57,70, 10);
		strokeWeight(1);		
		line(0, 0, vSize.x, 0);
		line(vSize.x, 0, vSize.x, vSize.y);
		line(vSize.x, vSize.y, 0, vSize.y);
		line(0, vSize.y, 0, 0);
		//grid
		//drawGrid();
		//obstacles
		noStroke();
		fill(70,140,136);
		for(int j=0;j<vCount.x;j++)
		{
			for(int k=0;k<vCount.y;k++)
			{
				if(grid[j][k].fCost < 1)
				{
					rect(j*vStep.x, k*vStep.y, vStep.x, vStep.y);
				}
			}
		}
	}
	void drawGrid()
	{
		//x		
		float temp = 0;
		for(i=0;i<vCount.x;i++)
		{
			temp = i*vStep.x;
			line(temp, 0, temp, vSize.y);
		}
		//y
		for(i=0;i<vCount.y;i++)
		{
			temp = i*vStep.y;
			line(0, temp, vSize.x, temp);
		}
	}
	void initGrid()
	{
		for(int j=0;j<vCount.x;j++)
		{
			for(int k=0;k<vCount.y;k++)
			{
				grid[j][k] = new PathNode(new PVector(j, k));
			}
		}
	}	
	void generateObstacles(float amount)
	{
		int total = (amount*vCount.x*vCount.y);
		for(int j=0;j<total;j++)
		{
			grid[int(random(vCount.x))][int(random(vCount.y))].fCost = 0;
		}
	}
	boolean isObstacle(PVector pos)
	{
		return grid[pos.x][pos.y].fCost == 0;
	}
	ArrayList getNeighbors(PVector pos)
	{
		ret = new ArrayList();
		if(pos.x>0 && !isObstacle(pos.x-1, pos.y))
		{
			//add left n
			ret.add(new PVector(pos.x-1, pos.y));
		}
		if(pos.x>0 && pos.y>0 && !isObstacle(pos.x-1, pos.y-1))
		{
			//add top left n
			ret.add(new PVector(pos.x-1, pos.y-1));
		}
		if(pos.x>0 && pos.y<vCount.y-1 && !isObstacle(pos.x-1, pos.y+1))
		{
			//add bottom left n
			ret.add(new PVector(pos.x-1, pos.y+1));	
		}
		if(pos.y>0 && !isObstacle(pos.x, pos.y-1))
		{
			//add top n
			ret.add(new PVector(pos.x, pos.y-1));
		}
		if(pos.x<vCount.x-1 && !isObstacle(pos.x+1, pos.y))
		{
			//add right n
			ret.add(new PVector(pos.x+1, pos.y));	
		}
		if(pos.y>0 && pos.x<vCount.x-1 && !isObstacle(pos.x+1, pos.y-1))
		{
			//add top right n
			ret.add(new PVector(pos.x+1, pos.y-1));
		}
		if(pos.y<vCount.y-1 && pos.x<vCount.x-1 && !isObstacle(pos.x+1, pos.y+1))
		{
			//add bottom right n
			ret.add(new PVector(pos.x+1, pos.y+1));
		}
		if(pos.y<vCount.y-1 && !isObstacle(pos.x, pos.y+1))
		{
			//add bottom n
			ret.add(new PVector(pos.x, pos.y+1));
		}
		return ret;
	}
	PVector getLocation(PVector pos)
	{
		return new PVector((pos.x*vStep.x)+left, (pos.y*vStep.y)+top);
	}
	PVector getPosition(PVector loc)
	{
		return new PVector(floor((loc.x-left)/vStep.x), floor((loc.y-top)/vStep.y));
	}
}

/*
 * REPRESENTATION of the NODE In the Grid
 */
class PathNode
{
	PVector vPosition;
	float fValue;
	float gValue;
	float hValue;
	float fCost;
	boolean bVisited;
	boolean bClosed;
	PathNode nParent;
	PathNode(PVector pos)
	{
		vPosition = pos
		fValue = 0;
		gValue = 0;
		hValue = 0;
		fCost = 1;
		bVisited = false;
		bClosed = false;
		nParent = null;
	}
	ArrayList getReversePath()
	{
		ret = new ArrayList();
		ret.add(this);
		temp = nParent;
		while(temp!=null)
		{
			ret.add(temp);
			temp = temp.nParent;
		}
		return ret;
	}
}
/*
 * BINARY HEAP tightly integrated with PathNode
 */
class BinaryHeap
{
	ArrayList alTree;
	BinaryHeap()
	{
		alTree = new ArrayList();
	}
	void push(PathNode value)
	{
		alTree.add(value);
		this.moveUp(this.alTree.size()-1);
	}
	PathNode pop()
	{
		if(alTree.size() == 0)
		{
			return null;
		}
		ret = PathNode(alTree.get(0));
		last = PathNode(alTree.remove(alTree.size()-1));
		if(alTree.size()>0)
		{
			alTree.set(0, last);
			this.moveDown(0);
		}
		return ret;
	}
	void moveUp(int idx)
	{
		currentIdx = idx;
		while(currentIdx > 0)
		{			
			currentNode = PathNode(alTree.get(currentIdx));
			parentIdx = (currentIdx+1 >> 1) - 1;
			parentNode = PathNode(alTree.get(parentIdx));
			//if parent less than child, swap.
			if(parentNode.fValue < currentNode.fValue)
			{
				alTree.set(parentIdx, currentNode);
				alTree.set(idx, parentNode);
				currentIdx = parentIdx;
			}else
			{
				break;
			}			
		}
	}
	void moveDown(int idx)
	{
		currentIdx = idx;
		currentNode = PathNode(alTree.get(currentIdx));
		child1Idx = (currentIdx + 1) << 1;
		child2Idx = child1Idx - 1;
		swapIdx = null;
		child1Node = null;
		child2Node = null;
		while(true)
		{
			if(child1Idx < alTree.size())
			{
				child1Node = PathNode(alTree.get(child1Idx));
				if(child1Node.fValue < currentNode.fValue)
				{
					swapIdx = child1Idx;
				}
			}
			if(child2Idx < alTree.size())
			{
				child2Node = PathNode(alTree.get(child2Idx));
				if(swapIdx == null && (child2Node.fValue < currentNode.fValue || child2Node.fValue < child1Node.fValue))
				{
					swapIdx = child2Idx;
				}
			}
			//do swap if found something smaller below
			if(swapIdx != null)
			{
				alTree.set(currentIdx, alTree.get(swapIdx));
				alTree.set(swapIdx, currentNode);
				currentIdx = swapIdx;
			}else
			{
				break;
			}
		}
	}
}