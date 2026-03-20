import ch.bildspur.artnet.*;



////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// HELLO THERE //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////




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




////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// WE SETUP HERE /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////



// user params
String IP = "127.0.0.1";
String XmlFilePath = "ArtnetSenderADM-WORKING.xml";
// String IP = "10.254.254.254";
// String IP = "192.168.1.245";
int linesAmount = 3;
boolean displayImage = false;
boolean blurImage = false;
int fps = 30;
float scale = 2;



// global variables and setup
ArtNetClient artnet;
byte[][] dmxDataArray = new byte[5][512];

byte[] dmxDataInput = new byte[512];

ArrayList<HLine> hLines = new ArrayList<HLine>();
PImage myImage;
PImage linesImage;
XML xml;


class XmlFixture
{
  int x, y, channelOffset;
  XmlFixture(int x, int y, int channelOffset)
  {
    this.x = x;
    this.y = y;
    this.channelOffset = channelOffset;
  }
}

ArrayList<XmlFixture> fixtures = new ArrayList<XmlFixture>();

void setup()
{
  size(560, 70, P2D);
  frameRate(fps);
  // myImage = loadImage("ColorGrid.png");
  // myImage = loadImage("ColorGrid2.png");
  // myImage = loadImage("Gradient.png");
  // myImage = loadImage("RainbowDiagonal.png");
  // myImage = loadImage("80x640ColorGrid.png");
  myImage = loadImage("InputMap-01.png");
  linesImage = loadImage("GradientLineVertical.png");
  createLines(linesAmount);
  textAlign(CENTER, CENTER);
  textSize(20);
  artnet = new ArtNetClient();
  artnet.start();
  readXml(XmlFilePath);
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
  float xpos, speed;
  float size;
  int ypos;
  int index;
  HLine (float x, float s, int y, int i)
  {
    xpos = x;
    speed = s;
    ypos = y;
    index = i;
  }

  void update(float amplitude, int rotate) {
    colorMode(HSB, 360, 100, 100);
    xpos += speed;
    if (xpos  > width)
    {
      xpos = 0   ;
    }
    int alpha = (int)(255 * amplitude);
    tint(colorLfo(0.5 * index * 0.05, 255 ), 100, 100, alpha);
    pushMatrix();
    translate(xpos + linesImage.width / 16, height / 4);
    rotate(radians(rotate));
    image(linesImage, -linesImage.width / 8, -height / 2, linesImage.width / 6, height * 4);
    popMatrix();
    noTint();
  }
}

// Function to create horizontal lines with random positions and speeds
void createLines( int amount) {
  for (int i = 0; i < amount; i++)
  {
    float xpos = i * width / amount;
    float speed = 1;
    float ypos = 0;
    hLines.add(new HLine(xpos, speed, (int)ypos, i));
  }
}


////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// WE DRAW HERE ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////



void draw()
{
  background(0);
  // read artnet data
  byte[] dataInput = artnet.readDmxData(0, 8);
  // int c = color(dataInput[0] & 0xFF, dataInput[1] & 0xFF, dataInput[2] & 0xFF);

  float rotate = ((dataInput[0] & 0xFF) / 255.0) * 40; // Map the first byte to a rotation angle between 0 and 360 degrees
  // scale viewport from the center
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
            XML[] Params = DmxSlice.getChildren("Params");
            XML[] ParamRange = Params[1].getChildren("ParamRange");
            int channelOffset = (int)ParamRange[0].getFloat("value");
            for (XML rect : InputRect)
            {              
              XML[] v = rect.getChildren("v");
              int centerX = (int)(v[0].getFloat("x") + (v[2].getFloat("x") - v[0].getFloat("x")) / 2);
              int centerY = (int)(v[0].getFloat("y") + (v[2].getFloat("y") - v[0].getFloat("y")) / 2);              
              XmlFixture fixture = new XmlFixture(centerX, centerY, channelOffset);
              fixtures.add(fixture);
            }
          }
        }
      }
    }
  }
  // println("Total InputRect centers: " + inputRectX.size());
  // println("Total InputRect centers: " + inputRectY.size());
}



// a function that scrapes pixel data based on the input rectangles defined in the resolume xml file
void scraperFromXml()
{
  colorMode(RGB, 255);
  loadPixels();

  for (int i = 0; i < fixtures.size(); i++)
  {
    int x = fixtures.get(i).x;
    int y = fixtures.get(i).y;
    int channelOffset = fixtures.get(i).channelOffset;

    int pos = (y * width + x) % (width * height);
    color currentPixel = pixels[constrain(pos, 0, pixels.length - 1)];

    int dmxIndex = channelOffset;
    int universe = dmxIndex / 512;
    int indexInUniverse = dmxIndex % 512;

    if (indexInUniverse < 512 - 3)
    {
      if (universe < dmxDataArray.length)
      {
        dmxDataArray[universe][indexInUniverse]     = (byte) red    (currentPixel);
        dmxDataArray[universe][indexInUniverse + 1] = (byte) green  (currentPixel);
        dmxDataArray[universe][indexInUniverse + 2] = (byte) blue   (currentPixel);
        dmxDataArray[universe][indexInUniverse + 3] = (byte) min(red(currentPixel), green(currentPixel), blue(currentPixel));
      }
    }
  }

  for (int i = 0; i < dmxDataArray.length; i++) {
    artnet.unicastDmx(IP, 0, i, dmxDataArray[i]);
  }
}
