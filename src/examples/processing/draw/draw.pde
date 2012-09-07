import processing.serial.*;

Serial myPort;

static final int DELAY = 50;

void setup()
{
  size(96*4, 64*4);
  fill(0);
  noStroke();
  
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 115200);
  myPort.bufferUntil(13);
  
  background(255);
}

void draw()
{
  
}

void mousePressed()
{
  ellipse(mouseX-mouseX%4, mouseY-mouseY%4, 4, 4);
  
  myPort.write((char)map(mouseX, 0, width, 0, 94));
  delay(DELAY);
  myPort.write((char)map(mouseY, 0, height, 0, 62));
  delay(DELAY);
}

void mouseDragged()
{
  ellipse(mouseX-mouseX%4, mouseY-mouseY%4, 4, 4);
  
  myPort.write((char)map(mouseX, 0, width, 0, 94));
  delay(DELAY);
  myPort.write((char)map(mouseY, 0, height, 0, 62));
  delay(DELAY);
}

void serialEvent (Serial myPort) {
}
