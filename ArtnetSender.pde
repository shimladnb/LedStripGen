



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
boolean displayImage = true;
boolean blurImage = false;
int fps = 30;
float scale = 1;





void setup()
{
  size(560, 70, P2D);
  frameRate(fps);
  myImage = loadImage("InputTester-01.png");
  linesImage = loadImage("GradientLineVertical.png");
  createLines(linesAmount);
  textAlign(CENTER, CENTER);
  textSize(20);
  artnet = new ArtNetClient();
  artnet.start();
  readXml(XmlFilePath);

  device = new AudioDevice(this, 44000, bands);
  r_width = width/float(bands);
  sample = new SoundFile(this, "beat.aiff");
  sample.loop();
  fft = new FFT(this, bands);
  fft.input(sample);
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

    fft.analyze();
  for (int i = 0; i < bands; i++) {
    
    // smooth the FFT data by smoothing factor
   sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;
    
    // draw the rects with a scale factor
    rect( i*r_width, height, r_width, -sum[i]*height*audioScale );
  }

  scraperFromXml();
}
