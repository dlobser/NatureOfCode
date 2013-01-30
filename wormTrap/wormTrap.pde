
float[] x = new float[20];
float[] y = new float[20];
float segLength = 18;

float q = 0;
float moveX = 320;
float moveY = 240;
int goX=1;
int goY=1;

void setup() {
  size(640, 360);
  strokeWeight(9);
  stroke(255, 100);
}

void draw() {

  
  background(0);
  mover();
  dragSegment(0, moveX,moveY);
  for(int i=0; i<x.length-1; i++) {
    dragSegment(i+1, x[i], y[i]);
  }
}

void dragSegment(int i, float xin, float yin) {
  float dx = xin - x[i];
  float dy = yin - y[i];
  float angle = atan2(dy, dx);  
  x[i] = xin - cos(angle) * segLength;
  y[i] = yin - sin(angle) * segLength;
  segment(x[i], y[i], angle,i);
}

void segment(float x, float y, float a,float myRad) {
  float ballSize = (map(myRad,0,20,30,0));
  pushMatrix();
  translate(x, y);
  rotate(a);
  ellipse(0,0,ballSize,ballSize);
  line(0, 0, segLength, 0);
  popMatrix();
}

void mover(){
  
    moveX += map(noise(q),0,.95,-15,15)*goX;
  moveY += map(noise(q+100),0,.95,-15,15)*goY;
  q+=.01;
  
  if(moveX<0)
 goX*=-1;
  if(moveX>width)
  goX*=-1;
   if(moveY<0)
 goY*=-1;
  if(moveY>height)
  goY*=-1;
}
