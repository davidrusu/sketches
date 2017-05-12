import processing.video.*;

PVector[] ps = new PVector[500];
Capture video;

void captureEvent(Capture c) {
  c.read();
}
void setup() {
  size(640, 480);
  video = new Capture(this, width, height);
  video.start();
  for (int i = 0; i < ps.length; i++) {
    ps[i] = new PVector(random(width), random(height));
  }
  noStroke();
}

float scaledNoise(float x, float y) {
  float scale = 0.01;
  return noise(x*scale, y*scale);
}

int pointColor(float x, float y) {
  //int c = color(scaledNoise(x, y) * 255);
  
  int c = video.get((int)x, (int)y);
  return c;
}

void draw() {
  fill(255, 0, 0);
  ps[0].x = mouseX;
  ps[0].y = mouseY;
  
  for (PVector p : ps) {
    rect(p.x, p.y, 2, 2);
  }
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      
      PVector closest = ps[0];
      float closest_d = dist(x, y, closest.x, closest.y);
      for (PVector p: ps) {
         float d = dist(p.x, p.y, x, y);
         if (d < closest_d) {
           closest = p;
           closest_d = d;
         }
      }
      int c = pointColor(closest.x, closest.y);
      pixels[x + width * y] = c;
    }
  }
  if (keyPressed && key == ' ') {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        pixels[x + width * y] = pointColor(x, y);
      }
    }
  }
  updatePixels();

}