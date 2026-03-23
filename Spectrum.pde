import processing.sound.*;

AudioIn input;

// Declare the processing sound variables 
SoundFile sample;
FFT fft;
AudioDevice device;

// Declare a scaling factor
int audioScale= 5;

// Define how many FFT bands we want
int bands = 128 * 2;

// declare a drawing variable for calculating rect width
float r_width;

// Create a smoothing vector
float[] sum = new float[bands];

// Create a smoothing factor
float smooth_factor = 0.1;

void drawAnalyzer() 
{
  fft.analyze();
  for (int i = 0; i < bands; i++) 
  {        
    sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;
    
    // draw the rects with a scale factor
    float hue = (i / float(bands)) * 90  + getNormalizedDmxValue(inputUniverse, 0) * 360;
    float saturation = getNormalizedDmxValue(inputUniverse, 1) * 100;
    float brightness = getNormalizedDmxValue(inputUniverse, 2) * 100;
    colorMode(HSB, 360, 100, 100);

    if (receivedDmxData(inputUniverse)) {
      fill(hue % 360, saturation, brightness);
    } else {
      fill(0, 100, 100);
    }

    strokeWeight(0);
    rect(i * r_width, height, r_width, -sum[i] * height * audioScale);
  }
}

void drawSegmentedLines(float heightOffset, float curve, int lineWeight)
{
    fft.analyze();
    for (int i = 0; i < bands; i++) 
    {
        sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;
        
        float hue = (i / float(bands)) * 90 + getNormalizedDmxValue(inputUniverse, 0) * 360;
        float saturation = getNormalizedDmxValue(inputUniverse, 1) * 100;
        float brightness = pow(getNormalizedDmxValue(inputUniverse, 2), 4) * 100;
        float audioBrightness = constrain(pow(sum[i] * 1000, curve) * brightness, 0, 100);        
        colorMode(HSB, 360, 100, 100);
        
        if (receivedDmxData(inputUniverse)) {
            stroke(hue % 360, saturation, audioBrightness);
        } else {
            stroke(0, 100, constrain(pow(sum[i] * 1000, curve) * 100, 0, 100)); 
        }
        
        strokeWeight(lineWeight);
        float segmentX1 = i * r_width;
        float segmentX2 = (i + 1) * r_width;
        float lineY = height / 2 - (sum[i] * height * audioScale) + heightOffset;
        lineY = sin(lineY) * (height / 4) + (height / 2);
        float nextLineY = (i + 1 < bands) ? height / 2 - (sum[i + 1] * height * audioScale) + heightOffset : lineY;
        nextLineY = sin(nextLineY) * (height / 4) + (height / 2);
        line(segmentX1, lineY, segmentX2, nextLineY);
    }
 }

float[] rayLifetime = new float[bands];
float[] rayDirection = new float[bands];
float rayThreshold = 0.05;
float raySpeed = 1;
float rayFadeSpeed = 4;

void drawPulseRays() 
{
  fft.analyze();
  
  float centerX = width / 2;
  float centerY = height / 2;
  
  for (int i = 0; i < bands; i++) {
    sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;
    
    // Spawn new rays if threshold reached
    if (sum[i] > rayThreshold && rayLifetime[i] <= 0) {
      rayLifetime[i] = 255;
      rayDirection[i] = random(1) > 0.5 ? 1 : -1; // Random left or right
    }
    
    // Update and draw existing rays
    if (rayLifetime[i] > 0) {
      float hue = (i / float(bands)) * 90 + getNormalizedDmxValue(inputUniverse, 0) * 360;
      float saturation = getNormalizedDmxValue(inputUniverse, 1) * 100;
      
      colorMode(HSB, 360, 100, 100);
      float alpha = pow(rayLifetime[i] / 255.0, 2) * 255;
      stroke(hue % 360, saturation, alpha);
      strokeWeight(2);
      
      float distance = (255 - rayLifetime[i]) / 255.0 * raySpeed * 100;
      float rayX = centerX + rayDirection[i] * distance;
      line(rayX, 0, rayX, height);
      
      rayLifetime[i] -= rayFadeSpeed;
    }
  }
}


