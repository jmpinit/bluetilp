import processing.serial.*;

static final int DELAY = 100;

PImage img;
Serial myPort;        // The serial port

void setup()
{
  size(96, 64);
  stroke(0);
  fill(0);
  
  img = loadImage("image.png");
  
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 115200);
  
  int count = 0;
  String combine = "";
  background(255);
  for(int y=0; y<64; y++){
    for(int x=0; x<12; x++){
      for(int i=0; i<8; i++){
        if(brightness(img.pixels[y*img.width+(x*8+i)])<128){
          combine += '1';
          point(x*8+i, y);
        }else{
          combine += '0';
        }
      }
      myPort.write(byte(unbinary(combine)));
      println(count);
      count++;
      combine = "";
      delay(DELAY);
    }
  }
  println("done");
  //background(255);
}
void draw ()
{
  
}

void plot(int x, int y)
{
  myPort.write(byte('P'));
  delay(DELAY);
  myPort.write(byte(x));
  delay(DELAY);
  myPort.write(byte(y));
  delay(DELAY);
}
