import ch.bildspur.artnet.*;

ArtNetClient artnet;
byte[] dmxData = new byte[512];
ArrayList<HLine> hLines = new ArrayList<HLine>();

// String IP = "192.168.1.245";
String IP = "127.0.0.1";
// String IP = "0.0.0.0";

int linesAmount = 20;


PImage myImage;

void setup()
{
  size(512, 512);

  //myImage = loadImage("ColorGrid.png");
  myImage = loadImage("ColorGrid2.png");
  //myImage = loadImage("Gradient.png");

  createLines();

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
  // image(myImage, 0, 0, width, height); //display the loaded image

  // update and display lines
  colorMode(HSB, 360, 100, 100);
  for (HLine line : hLines) {
    line.update();
  }
  colorMode(RGB,255);

  //scrape pixel data and convert to dmx values
  loadPixels(); 
  for (int i =0; i < (512 / 3); i++)
  {
    int scale = 1;
    int totalPixels = width * height;
    int pos = i * (totalPixels / 512 * 3) * scale;
    color currentPixel = pixels[pos % totalPixels];

    dmxData[i * 3]     = (byte) red    (currentPixel);
    dmxData[i * 3 + 1] = (byte) green  (currentPixel);
    dmxData[i * 3 + 2] = (byte) blue   (currentPixel);
  }

  // send dmx to localhost
  artnet.unicastDmx(IP, 0, 0, dmxData);
}

// Class representing a horizontal line that moves down the screen
class HLine 
{ 
  float ypos, speed;
  float size = random(10, 20); 
  HLine (float y, float s) {  
    ypos = y; 
    speed = s; 
  } 
  void update() { 
    ypos += speed; 
    if (ypos > width) { 
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

//
void createLines() {
  for (int i = 0; i < linesAmount; i++) 
  {
    float ypos = random(height);
    float speed = random(0.5, 2);
    hLines.add(new HLine(ypos, speed));
  }
}
