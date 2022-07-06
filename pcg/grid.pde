import java.util.Map;

class GridPoint{
  PVector normalized;
  int x;
  int y;
  PVector location;
  NoiseValues noiseValues;
  boolean river;
  Biome biome;
  boolean bridge;
  
  int gridSize;
  
  
  GridPoint (int x, int y, int gridSize){
    this.x = x;
    this.y = y;
    this.location = new PVector(x, y);
    this.gridSize = gridSize;
    this.noiseValues = new NoiseValues();
  }

  void renderGrid(){
    //render grid    
    rectMode(CENTER);
    stroke(0,0,0);
    noFill();
    square(x, y, gridSize);
  }
  
  void renderAltitude(){
    rectMode(CENTER);
    noStroke();
    
    fill(noiseValues.altitude * 255);
    square(x, y, gridSize);
  }
  
  void renderHumidity(){
    rectMode(CENTER);
    noStroke();
    
    fill(noiseValues.humidity * 255);
    square(x, y, gridSize);
  }
  
  void renderRainMap(){
    rectMode(CENTER);
    noStroke();
    
    fill(noiseValues.rain * 255);
    square(x, y, gridSize);
  }
  
  void renderRain(){
    //get random points within the square
    noStroke();
    if(biome.name.equals("snow") || biome.name.equals("rock")){
      fill(231, 241, 252);
    }
    else{
      fill(31, 96, 228 );
    }
    
    for(int i=0; i<2; i++){
      ellipse((int)random(x-(gridSize/2), x+(gridSize/2)), (int)random(y-(gridSize/2), y+(gridSize/2)), 2, 2);
    }
  }
  
  void renderBiome(){
    rectMode(CENTER);
    if(biome != null){
      if(bridge){
        if(river)
          fill(99, 60, 4);
        else
          fill(122, 81, 21);
      }else if(river){
        fill(biome.riverR, biome.riverG, biome.riverB);
      }else{
        fill(biome.r, biome.g, biome.b);
      }
      
    }else{
      fill(0);
    }
    
    square(x, y, gridSize);
  }
  
  void projectPerlin(float[][] perlinMap){
    this.noiseValues.altitude = perlinMap[y/gridSize][x/gridSize];
  }
  
  void projectValueNoise(float[][] valueNoiseMap){
    this.noiseValues.humidity = valueNoiseMap[y/gridSize][x/gridSize];
  }
  
  void projectValueNoiseRain(float[][] noiseMap){
    this.noiseValues.rain = noiseMap[y/gridSize][x/gridSize];
  }
}

class NoiseValues{
  //perlin
  float altitude;
  float humidity;
  float rain;
  
  public void generateAltitude(float x, float y){
    this.altitude = noise(x, y);
    this.humidity = 0.0f;
  }
}

ArrayList<GridPoint> createGrid(int interval){
  ArrayList<GridPoint> grid = new ArrayList();
  for(int x = 0; x <= width; x++){
    for(int y = 0; y <= height; y++){
      if(x % interval == 0 && y % interval == 0){
        grid.add(new GridPoint(x, y, interval));
      }
    }
  }
  return grid;
}

class Grid{
  List<Node<GridPoint>> nodes;
  ArrayList<Biome> biomes;
  
  //used as start and goal for river
  Node<GridPoint> high;
  Node<GridPoint> low;
  
  Map<PVector, Node<GridPoint>> nodeMap;
  
  int gridSize;
  
  GraphSearch<GridPoint> search;
  
  float[][] rainMap;
  
  Grid(int gridSize, GraphSearch search, ArrayList<Biome> biomes){
    this.gridSize = gridSize;
    this.search = search;
    this.biomes = biomes;
    nodeMap = new HashMap();
    generateNodes();
    createAltitude();
    createHumidity();
    matchBiomesToNodes();
    createEdges();
    createRiver();
    rainMap  = valueNoiseMap(4);
    createRain();
    biomeMetrics();
  }
  
  void generateNodes(){
    nodes = new ArrayList();
    for(int x = 0; x <= width; x++){
      for(int y = 0; y <= height; y++){
        if(x % gridSize == 0 && y % gridSize == 0){
          Node<GridPoint> node = new Node(new GridPoint(x, y, gridSize));
          nodes.add(node);
          nodeMap.put(node.value.location, node);
        }
      }
    }
  }
  
  void createAltitude(){
    float[][] altMap = perlinMap();
    for(Node<GridPoint> node : nodes){
      node.value.projectPerlin(altMap);
    }
  }
  
  void createHumidity(){
    float[][] humidityMap = valueNoiseMap(2);
    for(Node<GridPoint> node : nodes){
      node.value.projectValueNoise(humidityMap);
    }
  }
  
  void createRain(){
    //project rain map onto node
    for(Node<GridPoint> node : nodes){
      node.value.projectValueNoiseRain(rainMap);
    }
  }
  
  void translateRainMap(){
    //translate
    //[row][column]
    int y = height / GRID_SIZE;
    int x = width / GRID_SIZE;
    //[row][column] - loop through setting everything to +1 column, for last column, set to first
    
    float[][] copyMap = new float[y+1][x+1];
    
    for(int row = 0; row < rainMap.length; row++){
      for(int col = 0; col < rainMap[row].length; col++){
        //set col + 1 space
        if(col == rainMap[row].length - 1){
          copyMap[row][0] = rainMap[row][col];
        }else{
          copyMap[row][col+1] = rainMap[row][col];
        }
      }
    }
    
    rainMap = copyMap.clone();
    //recreate rain attr
    createRain();
  }
  
  void createEdges(){
    //conect nodes - will first need to call perlin.
    PVector x = new PVector(gridSize, 0);
    PVector y = new PVector(0, gridSize);
    
    for(Node<GridPoint> node : nodes){
      //only create edge if moving down in biome type, create heirarchy.
      //+/- x
      if(nodeMap.get(PVector.add(node.value.location, x))!= null){
        Node<GridPoint> toNode = nodeMap.get(PVector.add(node.value.location, x));
        if(node.value.biome.flow(toNode.value.biome)){
          node.edgeTo(toNode, sq(toNode.value.noiseValues.altitude * 100));
        }
      }
      if(nodeMap.get(PVector.sub(node.value.location, x))!= null){
        Node<GridPoint> toNode = nodeMap.get(PVector.sub(node.value.location, x));
        if(node.value.biome.flow(toNode.value.biome)){
          node.edgeTo(toNode, sq(toNode.value.noiseValues.altitude * 100));
        }
      }
      //+/- y
      if(nodeMap.get(PVector.add(node.value.location, y))!= null){
        Node<GridPoint> toNode = nodeMap.get(PVector.add(node.value.location, y));
        if(node.value.biome.flow(toNode.value.biome)){
          node.edgeTo(toNode, sq(toNode.value.noiseValues.altitude * 100));
        }     
      }
      if(nodeMap.get(PVector.sub(node.value.location, y))!= null){
        Node<GridPoint> toNode = nodeMap.get(PVector.sub(node.value.location, y));
        if(node.value.biome.flow(toNode.value.biome)){
          node.edgeTo(toNode, sq(toNode.value.noiseValues.altitude * 100));
        }
      }
    }
  }
  
  void matchBiomesToNodes(){
    for(Node<GridPoint> node : nodes){
      for(Biome biome : biomes){
        if(biome.matcheBiome(node.value.noiseValues.altitude, node.value.noiseValues.humidity)){
          node.value.biome = biome;
          break;
        }
      }
    }
  }

  void createRiver(){
    //this will be a find shortest path with search - then set those nodes to true - combine search and shortest path method
    //find high and low
    high = nodes.get(0);
    low = nodes.get(0);
    for(Node<GridPoint> node: nodes){
      if(high.value.noiseValues.altitude < node.value.noiseValues.altitude){
        high = node;
      }
      if(low.value.noiseValues.altitude > node.value.noiseValues.altitude){
        low = node;
      }
    }
    high.value.river = true;
    low.value.river = true;
    
    search.reset(high, low);
    List<Edge<GridPoint>> path = search.findPath();
    if(path != null){
      for(Edge<GridPoint> edge : path){
        edge.end.value.river = true;
        edge.start.value.river = true;
      }
      createBridge(path);
    }
  }
  
  void createBridge(List<Edge<GridPoint>> path){
    List<Node<GridPoint>> grassBiomes = new ArrayList();
    for(Edge<GridPoint> edge : path){
      //check if we are in grass biome, then check the adjacent non river cells
      if(edge.start.value.biome.canBridge()){
        int count = 0;
        for(Edge<GridPoint> out : edge.start.out){
          if(!out.end.value.river && out.end.value.biome.canBridge()){
            count+=1;
          }
          if(count >= 2){
            grassBiomes.add(edge.start);
          }
        }
      }
    }
    //randomly select a part of the river to bridge
    //can use random seed to move the bridge
    randomSeed(6);
    
    Node<GridPoint> bridge = grassBiomes.get(int(random(grassBiomes.size())));
    bridge.value.bridge = true;
    for(Edge<GridPoint> out : bridge.out){
      if(!out.end.value.river)
        out.end.value.bridge = true;
    }
    
  }
  
  void drawGrid(){
    for(Node<GridPoint> node : nodes){
      node.value.renderGrid();
    }
  }
  
  void drawAltitude(){
    for(Node<GridPoint> node : nodes){
      node.value.renderAltitude();
    }
  }
  
  void drawHumidity(){
    for(Node<GridPoint> node : nodes){
      node.value.renderHumidity();
    }
  }
  
  void drawRainMap(){
    for(Node<GridPoint> node : nodes){
      node.value.renderRainMap();
    }
  }
  
  void drawBiome(){
    for(Node<GridPoint> node : nodes){
      node.value.renderBiome();
    }
  }
  
  void drawRain(){
    for(Node<GridPoint> node : nodes){
      if(node.value.noiseValues.rain >= .6){
        node.value.renderRain();
      }
    }
  }
  
  void drawOutEdges(){
    stroke(1);
    stroke(222, 58, 33);
    for(Node<GridPoint> node : nodes){
      for(Edge<GridPoint> edge : node.out){
        line(edge.start.value.x, edge.start.value.y, edge.end.value.x, edge.end.value.y);
      }
    }
  }
  
  void biomeMetrics(){
    Map<String, Integer> count = new HashMap();
    for(Node<GridPoint> node : nodes){
      int c = count.getOrDefault(node.value.biome.name, 0);
      c++;
      count.put(node.value.biome.name, c);
    }
    println("---------Biome Metrics--------");
    for(Map.Entry entry : count.entrySet()){
      println((String)entry.getKey() + ": " + (Integer)entry.getValue());
    }
    println("----------------------");
  }

}
  
