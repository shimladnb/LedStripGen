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

void drawSegmentedLines()
{
    fft.analyze();
    for (int i = 0; i < bands; i++) 
    {
        sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;
        
        float hue = (i / float(bands)) * 90 + getNormalizedDmxValue(inputUniverse, 0) * 360;
        float saturation = getNormalizedDmxValue(inputUniverse, 1) * 100;
        float brightness = getNormalizedDmxValue(inputUniverse, 2) * 100;
        colorMode(HSB, 360, 100, 100);
        
        if (receivedDmxData(inputUniverse)) {
            stroke(hue % 360, saturation, brightness);
        } else {
            stroke(0, 100, 100);
        }
        
        strokeWeight(4);
        float segmentX1 = i * r_width;
        float segmentX2 = (i + 1) * r_width;
        float lineY = height / 2 - (sum[i] * height * audioScale);
        lineY = sin(lineY) * (height / 4) + (height / 2);
        float nextLineY = (i + 1 < bands) ? height / 2 - (sum[i + 1] * height * audioScale) : lineY;
        nextLineY = sin(nextLineY) * (height / 4) + (height / 2);
        line(segmentX1, lineY, segmentX2, nextLineY);
    }
 }
