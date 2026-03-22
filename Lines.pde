
ArrayList<HLine> hLines = new ArrayList<HLine>();
PImage linesImage;


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
