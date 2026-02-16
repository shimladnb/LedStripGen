import ch.bildspur.artnet.*;

ArtNetClient artnet;
byte[] dmxData = new byte[512];
ArrayList<HLine> hLines = new ArrayList<HLine>();

//String IP = "192.168.1.245";
String IP = "127.0.0.1";
// String IP = "0.0.0.0";

int linesAmount = 20;


PImage myImage;

void setup()
{
  size(512, 512);
  colorMode(RGB, 255);

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
  // create hueshift color
  

  background(0);
  // image(myImage, 0, 0, width, height); //display the loaded image

  for (HLine line : hLines) {
    line.update();
  }


  loadPixels(); //load pixels from screen into array
  for (int i =0; i < (512 / 3); i++)
  {
    int scale = 6;
    int totalPixels = width * height;
    int pos = i * (totalPixels / 512 * 3) * scale;
    color currentPixel = pixels[pos % totalPixels];

    dmxData[i * 3]     = (byte) red    (currentPixel);
    dmxData[i * 3 + 1] = (byte) green  (currentPixel);
    dmxData[i * 3 + 2] = (byte) blue   (currentPixel);
  }


  // send dmx to localhost
  artnet.unicastDmx(IP, 0, 0, dmxData);

  // show values
  //text("R: " + (int)red(c) + " Green: " + (int)green(c) + " Blue: " + (int)blue(c), width / 2, height / 2);
}

class HLine 
{ 
  float ypos, speed; 
  HLine (float y, float s) {  
    ypos = y; 
    speed = s; 
  } 
  void update() { 
    ypos += speed; 
    if (ypos > width) { 
      ypos = 0; 
    } 
    int c = color(colorLfo(0.1 * speed, 255), colorLfo(0.2 * speed, 255), colorLfo(0.3 * speed, 255));
    line(0, ypos, width, ypos); 
    stroke(c);
    strokeWeight(20);
  } 
} 

int colorLfo(float frequency, float amplitude) 
{
  return (int)(amplitude * (1 + sin(TWO_PI * frequency * frameCount / 60)) / 2);
}

void createLines() {
  for (int i = 0; i < linesAmount; i++) 
  {
    float ypos = random(height);
    float speed = random(0.5, 2);
    hLines.add(new HLine(ypos, speed));
  }
}
