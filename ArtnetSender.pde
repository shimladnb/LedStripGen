import ch.bildspur.artnet.*;

/*
  ArtnetSender.pde
  A simple Processing sketch that sends DMX data over Art-Net based on pixel data from an image.
  It also includes moving horizontal lines for visual effect.

  Make sure to include the ArtNet library in your Processing environment to run this code.

  todo:
  - 16 x 32 strips scraper
*/



ArtNetClient artnet;
byte[] dmxData = new byte[512];
ArrayList<HLine> hLines = new ArrayList<HLine>();

// String IP = "192.168.1.245";
String IP = "127.0.0.1";
// String IP = "0.0.0.0";

// user params
int linesAmount = 8;
boolean displayImage = false;
int fps = 30;
float scale = 1;
int amountOfStrips = 8;
int stripLength = 21;


PImage myImage;
PImage spoutImage; // Image to receive a texture
PGraphics pgr; // Canvas to receive a texture



void setup()
{
  size(8*20, 16*20);
  frameRate(fps);

  //myImage = loadImage("ColorGrid.png");
  // myImage = loadImage("ColorGrid2.png");
  //myImage = loadImage("Gradient.png");
  // myImage = loadImage("RainbowDiagonal.png");
  myImage = loadImage("80x640ColorGrid.png");

  createLines(linesAmount);

  //colorMode(RGB, 255);
  textAlign(CENTER, CENTER);
  textSize(20);

  // create artnet client without buffer (no receving needed)
  artnet = new ArtNetClient(null);
  artnet.start();
  
}

void draw()
{
  background(0);

  // display the loaded image (optional, can be commented out if not needed)
  if (displayImage) 
  {
    image(myImage, 0, 0, width, height);
  }
  

  // display and update horizontal lines
  for (HLine line : hLines) 
  {
    line.update();
  }

  // blur the image for a more dynamic effect (optional)
  filter(BLUR, 2);

  // scrape pixel data and convert to dmx values
  scraper();

  // send dmx to localhost
  artnet.unicastDmx(IP, 0, 0, dmxData);
}

// Class representing a horizontal line that moves down the screen
class HLine 
{ 
  float ypos, speed;
  float size = height / 10.0; 
  int position = 0;
  HLine (float y, float s, int pos) 
  {  
    ypos = y; 
    speed = s; 
    position = pos;
  } 

  void update() { 
    colorMode(HSB, 360, 100, 100);
    ypos += speed; 
    if (ypos > height) { 
      ypos = 0; 
    } 
    int c = color(colorLfo(0.1 * speed, 360), 100, 100);
    line(position, ypos, position + width / 8, ypos); 
    stroke(c);
    strokeWeight(size);
    strokeCap(SQUARE);
  } 
} 

// Function to create a color LFO (Low Frequency Oscillator) for dynamic color changes
int colorLfo(float frequency, float amplitude) 
{
  return (int)(amplitude * (1 + sin(TWO_PI * frequency * frameCount / 60)) / 2);
}

// Function to create horizontal lines with random positions and speeds
void createLines( int amount) {
  for (int i = 0; i < amount; i++) 
  {
    float ypos = random(height);
    float speed = random(0.5, 2);
    hLines.add(new HLine(ypos, speed, i * (width / amountOfStrips)));
  }
}

//scrape pixel data and convert to dmx values
void scraper()
{
  colorMode(RGB,255);
  loadPixels(); 

// scrape pixel data based on the number of strips and strip length
  for (int strip = 0; strip < amountOfStrips ; strip++) 
  {
    for (int pixel = 0; pixel < stripLength ; pixel++) 
    {
      int x = (strip * (width / amountOfStrips) + (width / (2 * amountOfStrips)));
      int y = (pixel * (height / stripLength) );
      int pos = (y * width + x) % (width * height);
      color currentPixel = pixels[constrain(pos, 0, pixels.length - 1)];

      int dmxIndex = (strip * stripLength + pixel) * 3;
      if (dmxIndex < dmxData.length - 2) 
      {
        dmxData[dmxIndex]     = (byte) red    (currentPixel);
        dmxData[dmxIndex + 1] = (byte) green  (currentPixel);
        dmxData[dmxIndex + 2] = (byte) blue   (currentPixel);
      }
    }
  }  
}
