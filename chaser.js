/*
 * chaser.js
 * Benchmark of pathfinding algorithms
 * Each chaser is represented by one of the algorithms
 * The speed of the chaser can be adjusted
 * A* with 2 different heuristics
 * Best-first
 * Djikstra
 *
 */
(function(){
	// setup here

})();

function Chaser(options)
{
	this.options = options;	
}
Chaser.prototype = {
	init: {

	},
	chase: {

	},
};

/*
 * Runner
 * Something to be chased, can be controlled with mouse
 */
function Runner(options)
{
	this.options = options;
}
Runner.prototype = {

};

/*
 * Grid
 * Logical representation of the grid-based world
 */
function Grid(options)
{
	this.options = options;
	this.runner = new Runner();
	this.chasers = [];
}
Grid.prototype = {
	init: {

	},
	draw: {

	}
};