


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
// String IP = "10.254.254.254";
// String IP = "192.168.1.245";
String XmlFilePath = "ArtnetSenderADM-WORKING.xml";
String imagePath = "InputTester-01.png";
int inputUniverse = 8;
int linesAmount = 4;
boolean drawAnalyzer = true;
boolean drawLines = false;
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

  if (displayImage)
  {
    image(myImage, 0, 0, width, height);
  }

  if (blurImage)
  {
    filter(BLUR, 2);
  }

  if (drawAnalyzer)
  {
    drawAnalyzer();
  }
  
  if (drawLines)
  {
    drawLines();
  }
  
  
  scraperFromXml();
}
