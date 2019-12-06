// -------------------------
// Perlin Noise 2D
// Mark Robitaille
// -------------------------

// CHANGE TO ALTER APPEARANCE
final int chunkType = 1; // 0 for Mountains, 1 for Islands, 2 for grasslands, 3 for deserts
final boolean overlappingWater = false;
final boolean useOctaves = true; // Use multiple octaves or not

float frequency; // Detail level of noise
float amplitude; // Range of noise
float lacunarity; // For inscreases in frequency with octaves
float persistence; // For inscreases in amplitude with octaves

// Height values for terrain
float baseHeight;
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
  smooth(4);
  noLoop();
  
  // Define terrain heights
  waterHeight = height - height/10;
  sandHeight = waterHeight - height/25;
  grassHeight = sandHeight - height/10;
  gravelHeight = grassHeight - height/3; 
  
  // Determine enviroment type's variable settings
  switch(chunkType) {
    case 1: // Island
      frequency = 4.0;
      amplitude = 320.0 + (float)Math.random()*320.0;
      lacunarity = 2.0;
      persistence = 0.5; 
      baseHeight = height/20.0;
      break;
    case 2: // Grassland
      frequency = 2.25;
      amplitude = height/10.0;
      lacunarity = 1.2;
      persistence = 1.5; 
      baseHeight = height/8.25;
      break;
    case 3: // Desert
      frequency = 3.0;
      amplitude = height/25.0;
      lacunarity = 1.0;
      persistence = 0.8; 
      baseHeight = height/10.0;
      break;
    default: // Mountain
      frequency = 4.0;
      amplitude = 640.0;
      lacunarity = 2.0;
      persistence = 0.5;  
      baseHeight = 0.0;
  }
  
  // Define the height map
  heightMap = new float[width+1];
  heightMapXScale = 1/((width-1)/2.0);
  heightMapXTranslation = -1.0;
  heightMapYScale = 2;
  heightMapYTranslation = -1.0;
  generateHeightMap();
  
}

void draw() {
  background(135,205,235);
  color(0,0,0);
  drawWater();
  drawLand();
  drawSun();
  drawHeightMapOutline();
  if (overlappingWater) {
    drawWater();
  }
}

// HEIGHT MAP FUNCTIONS

// Generate the height map 
void generateHeightMap() {
  if (useOctaves) {
    for (int i=0; i<heightMap.length; i++) {
      heightMap[i] = baseHeight + generateOctaveNoise((float)i/width, 8);
    }
  } else {
    for (int i=0; i<heightMap.length; i++) {
      heightMap[i] = baseHeight + generateNoise((float)i/width);
    }
  }
  
  if (chunkType==1) {
    makeIsland();
  }
}

// Makes things on the left and right have less amplitude
void makeIsland() {
  // Reduce amplitude between 20-35% of the way into the left or right
  float removalLeftInner = 0.2 + (float)Math.random()*0.15;
  float removalRightInner = 0.2 + (float)Math.random()*0.15;
  // Detemine index thatand left indexes
  int removalLeftInnerIndex =(int)(heightMap.length*removalLeftInner);
  int removalRightInnerIndex = (int)(heightMap.length*(1.0-removalRightInner));
  
  // Reduce left side
  for (int i=0; i<removalLeftInnerIndex; i++) {
    heightMap[i] = Math.max(25.0 + (float)Math.random()*5.0, heightMap[i]*(Math.abs(i-0))/removalLeftInnerIndex);
  }
  
  // Reduce right side
  for (int i=heightMap.length-1; i>removalRightInnerIndex; i--) {
    heightMap[i] = Math.max(25.0 + (float)Math.random()*5.0, heightMap[i]*(Math.abs(i-heightMap.length-1))/removalLeftInnerIndex);
  }
}

// NOISE FUNCTIONS

float generateOctaveNoise(float x, int octaves) {
  float localFrequency = frequency;
  float localAmplitude = 1;
  float noiseValue = 0;
  float amplitudeSum = 0;
   for (int i=0; i<octaves; i++) {
      noiseValue += noise(x * localFrequency + 1.0) * localAmplitude;
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
  for (int i=0; i<heightMap.length-1; i++) {
    line(i, height-heightMap[i],i+1,height-heightMap[i+1]);
  }
}

void drawLand() {
  for (int i=0; i<heightMap.length; i++) {
    boolean done = false;
    
    // Draw sand
    stroke(255,255,200);
    if (height-heightMap[i]<sandHeight) {
      line(i,height,i,sandHeight);
    } else {
      line(i,height,i,height-heightMap[i]); 
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
  rect(0,waterHeight, width, height-waterHeight);
}

void drawSun() {
  stroke(0,0,0);
  fill(250,185,20);
    ellipse(100, 100, 50,50);
}
