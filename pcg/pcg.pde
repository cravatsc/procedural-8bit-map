Grid grid;
ArrayList<Biome> biomes;

int GRID_SIZE = 10;

boolean drawGrid = true;
boolean drawPerlin = false;
boolean drawBiome = true;
boolean drawHumidity = false;
boolean drawRain = true;
boolean drawRainMap = false;
float heat = 0.0;
float precipitation = 0.5;
float seasonalIncrement = 0.001;

int FRAME_RATE = 10;



void setup() 
{
  frameRate(FRAME_RATE);
  size(800, 600);
  colorMode(RGB, 255);  
  noStroke();
  background(255,255, 255);
  noiseDetail(10);
  noiseSeed(4);
  
  biomes = generateBiomes();
  
  grid = new Grid(GRID_SIZE, new AStar<GridPoint>(new Manhattan()), biomes);
  //grid = new Grid(GRID_SIZE, new Dijkstras<GridPoint>(), biomes);

  //noLoop();
}

void draw() 
{ //<>//
  background(255, 255, 255);
  
  heat = heat+seasonalIncrement;
  seasonalIncrement = (heat > 1 || heat < 0) ? seasonalIncrement*-1 : seasonalIncrement;
  heat = Math.max(heat+seasonalIncrement, 0);
  
  if(frameCount%(FRAME_RATE/2) == 0){
    //every half second translate the rain map
    grid.translateRainMap();
  }
  
  grid.matchBiomesToNodes();
  
  if(drawPerlin){
    grid.drawAltitude();
  }
  if(drawBiome){
    grid.drawBiome();
    if(drawRain){
      grid.drawRain();
    }
  }
  if(drawHumidity){
    grid.drawHumidity();
  }
  if(drawRainMap){
    background(255, 255, 255);
    grid.drawRainMap();
  }
  if(drawGrid){
    grid.drawGrid();
  }
  //grid.drawOutEdges();
}
void keyTyped(){
  if (key == 'm'){
    grid.biomeMetrics();
  }
}
