import java.util.Arrays;

class Biome{
  Attribute altitude;
  Attribute humidity;
  Attribute heatAltVariance;
  Attribute rainVariance;
  int r;
  int g;
  int b;
  int riverR;
  int riverG;
  int riverB;
  String name;
  
  Biome(String name, Attribute altitude, Attribute humidity, Attribute heatAltVariance, Attribute rainVariance, int r, int g, int b, int riverR, int riverG, int riverB){
    this.name = name;
    this.altitude = altitude;
    this.humidity = humidity;
    this.heatAltVariance = heatAltVariance;
    this.rainVariance = rainVariance;
    this.r = r;
    this.g = g;
    this.b = b;
    this.riverR = riverR;
    this.riverG = riverG;
    this.riverB = riverB;
  }
  
  boolean matcheBiome(float altitude, float humidity){
    Attribute new_range = adjustWeather();
    return new_range.matches(altitude) && this.humidity.matches(humidity);
  }
  
  boolean flow(Biome otherBiome){
    return this.altitude.min == otherBiome.altitude.min || this.altitude.min >= otherBiome.altitude.max;
  }
  
  Attribute adjustWeather() {
    float minPoint = Math.min(this.altitude.min+this.heatAltVariance.min*heat, 1);
    float maxPoint = Math.min(this.altitude.max+this.heatAltVariance.max*heat, 1);
    minPoint = minPoint < 0 ? 0 : minPoint;
    maxPoint = maxPoint < 0 ? 0 : maxPoint;
    return new Attribute(minPoint, maxPoint);
  }
  
  public boolean equals(Object o){
    if(this == o)
      return true;
    if(!(o instanceof Biome))
      return false;
    Biome b = (Biome) o;
    return this.name.equals(b.name);
  }
  
  boolean canBridge(){
    return this.name.equals("grass") ||  this.name.equals("shallowJungle") || this.name.equals("deepJungle");
  }
}

class Attribute{
  float min;
  float max;
  
  Attribute(float min, float max){
    this.min = min;
    this.max = max;
  }
  
  boolean matches(float val){
    if(val > max){
      return false;
    }
    if(val < min){
      return false;
    }
    return true;
  }
}

ArrayList<Biome> generateBiomes(){
  ArrayList<Biome> biomes = new ArrayList();
  Biome snow = new Biome("snow", new Attribute(.66, 1), new Attribute(0, 1), new Attribute(0.05, 0), new Attribute(0, 0), 235,235,235, 100, 228, 237);
  Biome rock = new Biome("rock", new Attribute(.57, .66), new Attribute(0, 1), new Attribute(0, 0.05), new Attribute(0, 0), 161, 171, 161, 50, 168, 160);
  Biome grass = new Biome("grass", new Attribute(.4, .57), new Attribute(0, 0.5), new Attribute(0, 0), new Attribute(0, 0), 4, 170, 81, 3, 78, 252);
  Biome shallowJungle = new Biome("shallowJungle", new Attribute(.4, .57), new Attribute(0.5, 0.75), new Attribute(0, 0), new Attribute(0, 0), 34, 139, 34, 3, 78, 252);
  Biome deepJungle = new Biome("deepJungle", new Attribute(.4, .57), new Attribute(0.75, 1), new Attribute(0, 0), new Attribute(0, 0), 4, 78, 56, 3, 78, 252);
  Biome sand = new Biome("sand", new Attribute(.33,.4), new Attribute(0, 0.5), new Attribute(-0.05, 0), new Attribute(0, 0), 219, 212, 18, 3, 78, 252);
  Biome land = new Biome("land", new Attribute(.33,.4), new Attribute(0.5, 0.75), new Attribute(-0.05, 0), new Attribute(0, 0), 218, 165, 32, 3, 78, 252);
  Biome muddy = new Biome("muddy", new Attribute(.33,.4), new Attribute(0.75, 1), new Attribute(-0.05, 0), new Attribute(0, 0), 205, 133, 63, 3, 78, 252);
  Biome water = new Biome("water", new Attribute(0.25, .33), new Attribute(0, 1), new Attribute(0, -0.05), new Attribute(0, 0), 3, 78, 252, 3, 78, 252);
  Biome deepwater = new Biome("deepwater", new Attribute(0, .25), new Attribute(0, 1), new Attribute(0, 0), new Attribute(0, 0), 3, 70, 139, 3, 78, 252);
  
  biomes.addAll(Arrays.asList(snow, rock, grass, sand, muddy, land, water, shallowJungle, deepJungle, deepwater));
  return biomes;
}
