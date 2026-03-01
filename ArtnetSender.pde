import ch.bildspur.artnet.*;




/*
  ArtnetSender.pde
 A simple Processing sketch that sends DMX data over Art-Net based on pixel data from an image.
 It also includes moving horizontal lines for visual effect.
 
 Make sure to include the ArtNet library in your Processing environment to run this code.
 
 todo:
 - 16 x 32 strips scraper CHECK
 - add more visual effects
 - Artnet receiver to visualize incoming data CHECK
 - image files for lines
 - plan out Artnet control from the desk
 */




////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// WE SETUP HERE /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


// user params
String IP = "127.0.0.1";
// String IP = "10.254.254.254";
// String IP = "192.168.1.245";
int linesAmount = 7;
boolean displayImage = false;
boolean blurImage = true;
int fps = 30;
float scale = 1;
int amountOfStrips = 8;
int stripLength = 21;

// global variables
ArtNetClient artnet;
byte[] dmxData = new byte[512];
byte[] dmxDataInput = new byte[512];
ArrayList<HLine> hLines = new ArrayList<HLine>();
PImage myImage;
XML xml;
ArrayList<int[]> inputRectX = new ArrayList<int[]>();
ArrayList<int[]> inputRectY = new ArrayList<int[]>();

void setup()
{
  size(560, 70, P2D);
  frameRate(fps);
  //myImage = loadImage("ColorGrid.png");
  // myImage = loadImage("ColorGrid2.png");
  //myImage = loadImage("Gradient.png");
  // myImage = loadImage("RainbowDiagonal.png");
  // myImage = loadImage("80x640ColorGrid.png");
  myImage = loadImage("Horse.png");
  createLines(linesAmount);
  textAlign(CENTER, CENTER);
  textSize(20);
  artnet = new ArtNetClient();
  artnet.start();
  readXml("ArtnetSenderADM.xml");
}



////////////////////////////////////////////////////////////////////////////////////
/////////////////////////// WE DEFINE THE ARTSY STUFF HERE /////////////////////////
////////////////////////////////////////////////////////////////////////////////////



// Function to create a color LFO (Low Frequency Oscillator) for dynamic color changes
int colorLfo(float frequency, float amplitude)
{
  return (int)(amplitude * (1 + sin(TWO_PI * frequency * frameCount / 60)) / 2);
}

// Class representing a horizontal line that moves down the screen
class HLine
{
  float ypos, speed;
  float size = height / 10.0;
  int xpos;
  int index;
  HLine (float y, float s, int x, int i)
  {
    ypos = y;
    speed = s;
    xpos = x;
    index = i;
  }

  void update(float amplitude) {
    colorMode(HSB, 360, 100, 100);
    ypos += speed;
    if (ypos > height)
    {
      ypos = 0;
    }
    int c = color(colorLfo(0.1 * speed, 360) + (index * 20), 50, 100 * amplitude);
    line(xpos, ypos, width, ypos);
    stroke(c);
    strokeWeight(size);
    strokeCap(SQUARE);
  }
}

// Function to create horizontal lines with random positions and speeds
void createLines( int amount) {
  for (int i = 0; i < amount; i++)
  {
    float ypos = i * height / amount;
    float speed = .2;
    float xpos = 0;
    hLines.add(new HLine(ypos, speed, (int)xpos, i));
  }
}


////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// WE DRAW HERE ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////



void draw()
{
  background(0);

  // read artnet data
  byte[] dataInput = artnet.readDmxData(0, 0);
  // int c = color(dataInput[0] & 0xFF, dataInput[1] & 0xFF, dataInput[2] & 0xFF);
  // background(c);

  // display the loaded image
  if (displayImage)
  {
    image(myImage, 0, 0, width, height);
  }

  pushMatrix();
  scale(2);
  translate(width/4, height/4);
  // rotate(radians(frameCount % 360));
  translate(-width/2, -height/2);

  // display and update horizontal lines
  for (HLine line : hLines)
  {
    line.update(1.0);
  }
  popMatrix();


  if (blurImage)
  {
    filter(BLUR, 2);
  }



  // scraper();
  scraperFromXml();


}



////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// WE DO SOME NERDY STUFF HERE ///////////////////////////
////////////////////////////////////////////////////////////////////////////////////




// a function that reads an resolume xml file and extracts the color values for each fixture 
void readXml(String filePath)
{
  xml = loadXML(filePath);
  XML[] ScreenSetups = xml.getChildren("ScreenSetup");
  println("Number of ScreenSetups: " + ScreenSetups.length);
  for (XML ScreenSetup : ScreenSetups)
  {
    XML[] Screens = ScreenSetup.getChildren("screens");
    println("Number of Screens: " + Screens.length);
    for (XML Screen : Screens)
    {
      XML[] DmxScreens = Screen.getChildren("DmxScreen");
      println("Number of DmxScreens: " + DmxScreens.length);
      for (XML DmxScreen : DmxScreens)
      {
        XML[] Layers = DmxScreen.getChildren("layers");
        println("Number of Layers: " + Layers.length);
        for (XML Layer : Layers)
        {
          XML[] DmxSlices = Layer.getChildren("DmxSlice");
          println("Number of DmxSlices: " + DmxSlices.length);
          for (XML DmxSlice : DmxSlices)
          {
            XML[] InputRect = DmxSlice.getChildren("InputRect");
            // println("Number of InputRect: " + InputRect.length);
            for (XML rect : InputRect)
            {
              XML[] v = rect.getChildren("v");
              int centerX = v[0].getInt("x") + (v[2].getInt("x") - v[0].getInt("x")) / 2;
              int centerY = v[0].getInt("y") + (v[2].getInt("y") - v[0].getInt("y")) / 2;
              // println("center:" + centerX + ", " + centerY);
              inputRectX.add(new int[]{centerX});
              inputRectY.add(new int[]{centerY});
            }
          }
        }
      }
    }
  }
  // println("Total InputRect centers: " + inputRectX.size());
  // println("Total InputRect centers: " + inputRectY.size());
}


//scrape pixel data and convert to dmx values
void scraper()
{
  colorMode(RGB, 255);
  loadPixels();

  // scrape pixel data based on the number of strips and strip length
  for (int strip = 0; strip < amountOfStrips; strip++)
  {
    for (int pixel = 0; pixel < stripLength; pixel++)
    {
      int x = (strip * (width / amountOfStrips) + (width / (2 * amountOfStrips)));
      int y = (pixel * (height / stripLength) );
      int pos = (y * width + x) % (width * height);
      color currentPixel = pixels[constrain(pos, 0, pixels.length - 1)];

      int dmxIndex = (strip * stripLength + pixel) * 4;
      if (dmxIndex < dmxData.length - 3)
      {
        dmxData[dmxIndex]     = (byte) red    (currentPixel);
        dmxData[dmxIndex + 1] = (byte) green  (currentPixel);
        dmxData[dmxIndex + 2] = (byte) blue   (currentPixel);
        dmxData[dmxIndex + 3] = (byte) min(red(currentPixel), green(currentPixel), blue(currentPixel));
      }
    }
  }
  artnet.unicastDmx(IP, 0, 0, dmxData);
}



// a function that scrapes pixel data based on the input rectangles defined in the resolume xml file
void scraperFromXml()
{
  colorMode(RGB, 255);
  loadPixels();

  for (int i = 0; i < inputRectX.size(); i++)
  {
    int x = inputRectX.get(i)[0];
    int y = inputRectY.get(i)[0];
    int pos = (y * width + x) % (width * height);
    color currentPixel = pixels[constrain(pos, 0, pixels.length - 1)];

    int dmxIndex = i * 4;
    if (dmxIndex < dmxData.length - 3)
    {
      dmxData[dmxIndex]     = (byte) red    (currentPixel);
      dmxData[dmxIndex + 1] = (byte) green  (currentPixel);
      dmxData[dmxIndex + 2] = (byte) blue   (currentPixel);
      dmxData[dmxIndex + 3] = (byte) min(red(currentPixel), green(currentPixel), blue(currentPixel));
    }
  }
  artnet.unicastDmx(IP, 0, 0, dmxData);
}
