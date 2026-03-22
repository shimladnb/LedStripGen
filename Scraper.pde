import ch.bildspur.artnet.*;


// global variables and setup
ArtNetClient artnet;
byte[][] dmxDataArray = new byte[4][512];


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

    int dmxIndex = channelOffset - 1;
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


float getNormalizedDmxValue(int universe, int channel)
{
  byte[] artnetInput = artnet.readDmxData(0, universe);
  if (channel >= 0 && channel < artnetInput.length)
  {
    return (artnetInput[channel] & 0xFF) / 255.0;
  }
  return 0.0;
}


