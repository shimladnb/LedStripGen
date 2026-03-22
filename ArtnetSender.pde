


/*
  Written by Sem Schreuder, 2026
 
 A Processing sketch that sends DMX data over Art-Net based on pixel data from the viewport.
 Make sure to include the ArtNet library in your Processing environment to run this code.
 
 todo:
 - 16 x 32 strips scraper CHECK
 - add more visual effects
 - Artnet receiver to visualize incoming data CHECK
 - image files for lines CHECK
 - plan out Artnet control from the desk CHECK
 - read resolume xml for scraping CHECK
 */



// user params
String IP = "127.0.0.1";
String XmlFilePath = "ArtnetSenderADM-WORKING.xml";
String imagePath = "InputTester-01.png";
// String IP = "10.254.254.254";
// String IP = "192.168.1.245";
int linesAmount = 5;
boolean displayImage = false;
boolean blurImage = false;
int fps = 30;
float scale = 1;
PImage myImage;



void setup()
{
  size(560, 70, P2D);
  frameRate(fps);
  myImage = loadImage(imagePath);
  linesImage = loadImage("GradientLineVertical.png");
  createLines(linesAmount);
  textAlign(CENTER, CENTER);
  textSize(20);
  artnet = new ArtNetClient();
  artnet.start();
  readXml(XmlFilePath);

  input = new AudioIn(this, 0);
  input.start();
  r_width = width/float(bands);
  fft = new FFT(this, bands);
  fft.input(input);
}


void draw()
{
  background(0);



  float rotate = getNormalizedDmxValue(8,1) * 40; 
  translate(width / 2, height / 2);
  scale(scale);
  translate(-width / 2, -height / 2);

  for (HLine line : hLines)
  {
    line.update(1.0, (int)rotate);
  }

  if (displayImage)
  {
    image(myImage, 0, 0, width, height);
  }

  if (blurImage)
  {
    filter(BLUR, 2);
  }

  fft.analyze();
  for (int i = 0; i < bands; i++) 
  {        
    sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;
    
    // draw the rects with a scale factor
    float hue = (i / float(bands)) * 90  + getNormalizedDmxValue(8, 0) * 360;
    float saturation = getNormalizedDmxValue(8, 1) * 100;
    float brightness = getNormalizedDmxValue(8, 2) * 100;
    hue = hue % 360;
    colorMode(HSB, 360, 100, 100);
    fill(hue, saturation, brightness);
    strokeWeight(0);
    rect(i * r_width, height, r_width, -sum[i] * height * audioScale);
  }

  scraperFromXml();
}
