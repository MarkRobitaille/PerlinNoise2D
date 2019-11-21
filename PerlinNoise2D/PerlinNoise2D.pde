final float frequency = 4.0;
//final float amplitude = 2.0;
final float amplitude = 640.0;
final float lacunarity  = 2.0; // For inscreases in frequency with octaves
final float persistence = 0.5; // For inscreases in amplitude with octaves

final boolean useOctaves = true;
final boolean island = true;

float waterHeight;
float sandHeight;
float grassHeight;
float gravelHeight; 

float[] heightMap;
float heightMapXScale; // Used to scale heightMap's index values into the window's 2.0 width
float heightMapXTranslation; // Used to center heightmap into 
float heightMapYScale;
float heightMapYTranslation; // Used to center within 2.0 height;

void setup() {
  // General Processing setup
  size(640,640, P3D);
  hint(DISABLE_OPTIMIZED_STROKE);
  //smooth(1);
  noLoop();
  
  // Define the height map
  heightMap = new float[width];
  heightMapXScale = 1/((width-1)/2.0);
  heightMapXTranslation = -1.0;
  heightMapYScale = 2;
  heightMapYTranslation = -1.0;
  generateHeightMap();
  
  waterHeight = height - height/10;
  sandHeight = waterHeight - height/30;
  grassHeight = sandHeight - height/20;
  gravelHeight = grassHeight - height/3; 
}

void draw() {
  background(135,205,235);
  color(0,0,0);
  //strokeWeight(2);
  //generateHeightMap();
  
  drawIsland();
  drawSun();
  drawHeightMapOutline();
  drawWater();
}

// HEIGHT MAP FUNCTIONS

// Generate the height map 
void generateHeightMap() {
  float max = -3;
  float min = 3;
  //heightMap[0] = test(0.0, 8);
  if (useOctaves) {
    for (int i=0; i<heightMap.length; i++) {
      heightMap[i] = generateOctaveNoise((float)i/width, 8);
      if (heightMap[i]>max) {
        max = heightMap[i];
      }
      if (heightMap[i]<min) {
        min = heightMap[i];
      }
    }
  } else {
    for (int i=0; i<heightMap.length; i++) {
      heightMap[i] = generateNoise((float)i/width);
      if (heightMap[i]>max) {
        max = heightMap[i];
      }
      if (heightMap[i]<min) {
        min = heightMap[i];
      }
    }
  }
  System.out.println("Max found was " + max);
  System.out.println("Min found was " + min);
  
  if (island) {
    makeIsland();
  }
}

// Makes things on the left 25% and right 25% have less amplitude
void makeIsland() {
  float maxRemoval = amplitude * 0.7;
  int firstQuarterIndex =(int)(heightMap.length/4);
  int thirdQuarterIndex = (int)(heightMap.length*0.75);
  
  for (int i=0; i<firstQuarterIndex; i++) {
    heightMap[i] = Math.max(0, heightMap[i]*(Math.abs(i-0))/firstQuarterIndex);
  }
  
  for (int i=heightMap.length-1; i>thirdQuarterIndex; i--) {
    heightMap[i] = Math.max(0, heightMap[i]*(Math.abs(i-heightMap.length-1))/firstQuarterIndex);
  }
  System.out.println(maxRemoval);
}

// NOISE FUNCTIONS

float generateOctaveNoise(float x, int octaves) {
  float localFrequency = frequency;
  float localAmplitude = 1;
  float noiseValue = 0;
  float amplitudeSum = 0;
   for (int i=0; i<octaves; i++) {
      noiseValue += noise(x * localFrequency) * localAmplitude;
      amplitudeSum += localAmplitude;
      localFrequency *= lacunarity;
      localAmplitude *= persistence;
   }
   return noiseValue/amplitudeSum * amplitude; // To scale to our intended amplitude
} 


float generateNoise(float x) {
  return noise(x * frequency) * amplitude;
}


// DRAWING FUNCTIONS

void drawHeightMapOutline() {
  stroke(0,0,0);
  //strokeWeight(2);
  //float max = -1;
  for (int i=0; i<heightMap.length-1; i++) {
    //line((float)i * heightMapXScale + heightMapXTranslation,heightMap[i] + heightMapYTranslation,
    //(float)(i+1) * heightMapXScale + heightMapXTranslation,heightMap[i+1] + heightMapYTranslation);
    line(i, height-heightMap[i],i+1,height-heightMap[i+1]);
  }
System.out.println("Max X drawn was " + (height-heightMap[240]));
}

void drawIsland() {
  
  for (int i=0; i<heightMap.length-1; i++) {
    //line((float)i * heightMapXScale + heightMapXTranslation,-1,
    //(float)i * heightMapXScale + heightMapXTranslation,heightMap[i+1] + heightMapYTranslation);  
    
    boolean done = false;
    
    // Draw sand
    stroke(255,255,200);
    if (height-heightMap[i]<sandHeight) {
      line(i,height,i,sandHeight);
    } else if (height-heightMap[i]<=waterHeight) {
      line(i,waterHeight,i,height-heightMap[i]);  
      done = true;
    } else {
      done = true;
    }
    
    float padding = (float)Math.random()*3.0;
    
    // Draw grass
    stroke(0,130,0);
    if (!done && height-heightMap[i]<grassHeight) {
      line(i,sandHeight+padding,i,grassHeight);
    } else if (!done) {
      line(i,sandHeight+padding,i,height-heightMap[i]);  
      done = true;
    }
    
    padding = (float)Math.random()*3.0;
    
    // Draw gravel
    stroke(100,50,0);
    if (!done && height-heightMap[i]<gravelHeight) {
      line(i,grassHeight+padding,i,gravelHeight);
    } else if (!done) {
      line(i,grassHeight+padding,i,height-heightMap[i]); 
      done = true;
    }
    
    padding = (float)Math.random()*3.0;
    
    // Draw ice
    stroke(248,248,255);
    if (!done && height-heightMap[i]<gravelHeight) {
      line(i,gravelHeight+padding,i,height-heightMap[i]);
    }
    
  }
}

void drawWater() {
  line(0,waterHeight, width, waterHeight);
  fill(0,120,190);
  noStroke();
  System.out.println(waterHeight);
  rect(0,waterHeight, width, height-waterHeight);
}
void drawSun() {
  stroke(0,0,0);
  fill(250,185,20);
  //ellipse(-0.7, 0.7, 0.25,0.25);
    ellipse(100, 100, 50,50);
}
