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
int linesAmount = 0;
int fps = 30;
float scale = 1;
int amountOfStrips = 8;
int stripLength = 64;

PImage myImage;
PImage spoutImage; // Image to receive a texture
PGraphics pgr; // Canvas to receive a texture



void setup()
{
  size(8*10, 64*10);
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
  image(myImage, 0, 0, width, height); 

  // display and update horizontal lines
  colorMode(HSB, 360, 100, 100);
  for (HLine line : hLines) 
  {
    line.update();
  }

  // blur the image for a more dynamic effect (optional)
  filter(BLUR, 1);

  // scrape pixel data and convert to dmx values
  scraper();

  // send dmx to localhost
  artnet.unicastDmx(IP, 0, 0, dmxData);
}

// Class representing a horizontal line that moves down the screen
class HLine 
{ 
  float ypos, speed;
  float size = random(1, 20); 
  HLine (float y, float s) {  
    ypos = y; 
    speed = s; 
  } 

  void update() { 
    ypos += speed; 
    if (ypos > height) { 
      ypos = 0; 
    } 
    int c = color(colorLfo(0.1 * speed, 360), 100, 100);
    line(0, ypos, width, ypos); 
    stroke(c);
    strokeWeight(size);
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
    hLines.add(new HLine(ypos, speed));
  }
}

//scrape pixel data and convert to dmx values
void scraper()
{
  colorMode(RGB,255);
  loadPixels(); 
  // for (int i =0; i < (512 / 3); i++)
  // {
  //   int totalPixels = width * height;
  //   int pos = (int)(i * (totalPixels / 512 * 3) * scale);
  //   color currentPixel = pixels[pos % totalPixels];

  //   dmxData[i * 3]     = (byte) red    (currentPixel);
  //   dmxData[i * 3 + 1] = (byte) green  (currentPixel);
  //   dmxData[i * 3 + 2] = (byte) blue   (currentPixel);
  // }

// scrape pixel data based on the number of strips and strip length
  for (int strip = 0; strip < amountOfStrips ; strip++) 
  {
    for (int pixel = 0; pixel < stripLength ; pixel++) 
    {
      int scaleX, scaleY;
      scaleX = 1;
      scaleY = 3;
      
      int x = (strip * (width / amountOfStrips) + (width / amountOfStrips) / 2);
      int y = (pixel * (height / stripLength) + (height / stripLength) / 2);
      int pos = ((y * scaleY) * width + (x * scaleX)) % (width * height);
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
