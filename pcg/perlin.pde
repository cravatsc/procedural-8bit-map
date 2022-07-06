public float[][] perlinMap(){
  float samplePerVert = 10.0f;
  int y = height / GRID_SIZE;
  int x = width / GRID_SIZE;
  println(x,y);
  //[row][column]
  float[][] noiseMap = new float[y+1][x+1];

    rectMode(CENTER);
    //stroke(0,0,0);
    noStroke();
    
    fill(0);
    square(200, 200, 20);
  
  for(int i = 0; i <= y; i++){
    for(int j = 0; j <= x; j++){
      float a = noise(j/samplePerVert, i/samplePerVert);
      noiseMap[i][j] = a;     
    }
  }
  return noiseMap;
}
