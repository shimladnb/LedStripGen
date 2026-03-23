void drawScreenStrobe(float strobeSpeed) 
{
  float strobeFrequency = strobeSpeed / frameRate;
  if (sin(frameCount * strobeFrequency * TWO_PI) > 0) {
    colorMode(RGB);
    fill(255);
    stroke(255);
    rect(0, 0, width, height);
  }
}
