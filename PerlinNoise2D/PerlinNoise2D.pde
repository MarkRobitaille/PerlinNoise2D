
float[] heightMap;
float heightMapXScale; // Used to scale heightMap's index values into the window's 2.0 width
float heightMapXTranslation; // Used to center heightmap into 
float heightMapYScale;
float heightMapYTranslation; // Used to center within 2.0 height;


void setup() {
  // General Processing setup
  size(640,640, P3D);
  ortho(-1,1,1,-1);
  hint(DISABLE_OPTIMIZED_STROKE);
  smooth(1);
  noLoop();
  
  // Define the height map
  heightMap = new float[width];
  heightMapXScale = 1/((width-1)/2.0);
  heightMapXTranslation = -1.0;
  heightMapYScale = 2;
  heightMapYTranslation = -0.5;
  generateHeightMap();
}

void draw() {
  resetMatrix();
  background(255,255,255);
  color(0,0,0);
  //generateHeightMap();
  drawHeightMapOutline();
}

// Generate the height map 
void generateHeightMap() {
  float max = -3;
  float min = 3;
  for (int i=0; i<heightMap.length; i++) {
    heightMap[i] = generateHeight((float)i);
    //heightMap[i] = generateHeight((float)i * heightMapXScale + heightMapXTranslation); //Apply scale to perlin noise?
    if (heightMap[i]>max) {
      max = heightMap[i];
    }
    if (heightMap[i]<min) {
      min = heightMap[i];
    }
  }
  System.out.println("Max found was " + max);
  System.out.println("Min found was " + min);
}

float generateHeight(float x) {
  return noise(x);
  //return (float)Math.random();
}

void drawHeightMapOutline() {
  float max = -1;
  for (int i=0; i<heightMap.length-1; i++) {
    line((float)i * heightMapXScale + heightMapXTranslation,heightMap[i] + heightMapYTranslation,
    (float)(i+1) * heightMapXScale + heightMapXTranslation,heightMap[i+1] + heightMapYTranslation);  
  }
System.out.println("Max X drawn was " + max);
}
