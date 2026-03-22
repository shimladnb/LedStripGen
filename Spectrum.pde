import processing.sound.*;

AudioIn input;

// Declare the processing sound variables 
SoundFile sample;
FFT fft;
AudioDevice device;

// Declare a scaling factor
int audioScale=5;

// Define how many FFT bands we want
int bands = 16;

// declare a drawing variable for calculating rect width
float r_width;

// Create a smoothing vector
float[] sum = new float[bands];

// Create a smoothing factor
float smooth_factor = 0.08;

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