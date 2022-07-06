
import java.util.*;

class ValueNoise 
{ 
  int kMaxTableSize = 256;
  int kMaxVertices = 256;
  int kMaxTableSizeMask = kMaxTableSize - 1;
  int kMaxVerticesMask = kMaxVertices - 1;
  float r[][]; 
  
  public float fxSmoothstep(float x){
    float y = x*x*(3 - 2*x);
    return y; 
  }
  
  public ValueNoise(int seed) 
  { 
    int y = height / GRID_SIZE;
    int x = width / GRID_SIZE;
    r = new float[256][256];
    Random random = new Random(seed);
    // create an array of random values
    for (int i = 0; i < 256; i++) {
      for (int j=0; j< 256; j++) {
        r[i][j] = random.nextFloat();
      }
    } 
  } 
 
    float eval(PVector p)  
    { 
        int xi = (int)p.x; 
        int yi = (int)p.y;
 
        float tx = p.x - xi; 
        float ty = p.y - yi;
 
        int rx0 = xi & kMaxTableSizeMask; 
        int rx1 = (rx0 + 1) & kMaxTableSizeMask; 
        int ry0 = yi & kMaxTableSizeMask; 
        int ry1 = (ry0 + 1) & kMaxTableSizeMask; 
 
        // random values at the corners of the cell using permutation table
        float c00 = r[ry0][rx0]; 
        float c10 = r[ry0][rx1]; 
        float c01 = r[ry1][rx0]; 
        float c11 = r[ry1][rx1]; 
 
        // remapping of tx and ty using the Smoothstep function 
        float sx = fxSmoothstep(tx); 
        float sy = fxSmoothstep(ty); 
 
        // linearly interpolate values along the x axis
        float nx0 = lerp(c00, c10, sx); 
        float nx1 = lerp(c01, c11, sx); 
 
        // linearly interpolate the nx0/nx1 along they y axis
        return lerp(nx0, nx1, sy); 
    }
};

public float[][] valueNoiseMap(int seed){
  int y = height / GRID_SIZE;
  int x = width / GRID_SIZE;
  //println(x,y);
  //[row][column]
  float[][] noiseMap = new float[y+1][x+1];
  
  // generate value noise
  ValueNoise noise = new ValueNoise(seed); 
  float frequency = 0.05f; 
  for (int i = 0; i <= y; i++) { 
    for (int j = 0; j <= x; j++) { 
      // generate a float in the range [0:1]
      PVector vec = new PVector(i,j);
      vec.mult(frequency);
      noiseMap[i][j] = noise.eval(vec); 
    } 
  } 
  
  return noiseMap;
}
