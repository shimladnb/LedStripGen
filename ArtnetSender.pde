import ch.bildspur.artnet.*;

ArtNetClient artnet;
byte[] dmxData = new byte[512];

PImage myImage;

void setup()
{
  size(512 / 3 , 1);


  myImage = loadImage("hq720.jpg"); // load an image


  colorMode(HSB, 360, 100, 100);
  textAlign(CENTER, CENTER);
  textSize(20);

  // create artnet client without buffer (no receving needed)
  artnet = new ArtNetClient(null);
  artnet.start();
}

void draw()
{
  // create color
  int c = color(frameCount % 360, 80, 100);

  background(c);
  image(myImage, 0, 0, width, height); //display the loaded image
  int totalPixels = width * height;
  println(totalPixels);

  loadPixels(); //load pixels from screen into array
  for (int i =0; i < totalPixels; i++)
  {
    dmxData[i * 3] =   (byte) red(pixels[i]);
    dmxData[i * 3 + 1] = (byte) green(pixels[i]);
    dmxData[i * 3 + 2] = (byte) blue(pixels[i]);
  }


  // send dmx to localhost
  artnet.unicastDmx("127.0.0.1", 0, 0, dmxData);

  // show values
  //text("R: " + (int)red(c) + " Green: " + (int)green(c) + " Blue: " + (int)blue(c), width / 2, height / 2);
}
