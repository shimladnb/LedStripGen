import ch.bildspur.artnet.*;

ArtNetClient artnet;
byte[] dmxData = new byte[512];

//String IP = "192.168.1.245";
String IP = "127.0.0.1";


PImage myImage;

void setup()
{
  size(512, 512);
  colorMode(RGB, 255);

  //myImage = loadImage("ColorGrid.png");
  myImage = loadImage("ColorGrid2.png");
  //myImage = loadImage("Gradient.png");


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
  //int c = color(frameCount % 360, 80, 100);

  background(0);
  image(myImage, 0, 0, width, height); //display the loaded image


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
