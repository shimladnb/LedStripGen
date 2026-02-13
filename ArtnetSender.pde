import ch.bildspur.artnet.*;

ArtNetClient artnet;
byte[] dmxData = new byte[512];


PImage myImage;

void setup()
{
  size(800 , 200);


  myImage = loadImage("ColorGrid.png"); // load an image


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
  int totalPixels = width * height;

  loadPixels(); //load pixels from screen into array
  for (int i =0; i < (512 / 3); i++)
  {
    dmxData[i * 3] =   (byte) red(pixels[(totalPixels / 512) * i]);
    dmxData[i * 3 + 1] = (byte) green(pixels[(totalPixels / 512) * i]);
    dmxData[i * 3 + 2] = (byte) blue(pixels[(totalPixels / 512) * i]);
    
    println((totalPixels / 512) * i);
  }


  // send dmx to localhost
  artnet.unicastDmx("127.0.0.1", 0, 0, dmxData);

  // show values
  //text("R: " + (int)red(c) + " Green: " + (int)green(c) + " Blue: " + (int)blue(c), width / 2, height / 2);
}
