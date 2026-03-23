
/*
  Written by Sem Schreuder, 2026
 
 A Processing sketch that sends DMX data over Art-Net based on pixel data from the viewport.
 Make sure to include the ArtNet library in your Processing environment to run this code.

*/


// user params
String IP = "127.0.0.1";
// String IP = "10.254.254.254";
// String IP = "192.168.1.245";
String XmlFilePath = "ArtnetSenderADM-WORKING.xml";
String imagePath = "InputTester-01.png";
int inputUniverse = 8;
int linesAmount = 4;

boolean Lines = false;
boolean Analyzer = false;
boolean SegmentedLines = true;
boolean PulseRays = true;
boolean Strobe = false;

boolean Image = false;
boolean blur = false;

float curve = 1;
int fps = 30;
float scale = 1.5;
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
  pushMatrix();
  translate(width/2, height/2);
  scale(scale);
  translate(-width/2, -height/2);

  if (Analyzer)
  {
    drawAnalyzer();
  }

  if (Lines)
  {
    drawLines();
  }

  if (SegmentedLines)
  {
    drawSegmentedLines(-40, 8 * curve, 1);
    drawSegmentedLines(0, 2 * curve, 4);
    drawSegmentedLines(40, 8 * curve, 1);
  }

  if (PulseRays)
  {
    drawPulseRays();
  }

  if (Strobe)
  {
    drawScreenStrobe(10);
  }

  popMatrix();

  if (Image)
  {
    image(myImage, 0, 0, width, height);
  }

  if (blur)
  {
    filter(BLUR, 4);
  }

  keyPressed(key);

  scraperFromXml();
}

void keyPressed(char key) {
  switch(key) {
    case '1':
      Analyzer = !Analyzer;
      break;
    case '2':
      Lines = !Lines;
      break;
    case '3':
      SegmentedLines = !SegmentedLines;
      break;
    case '4':
      Image = !Image;
      break;
  }
}
