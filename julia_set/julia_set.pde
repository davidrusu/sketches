void setup() {
  size(640, 640);
  noiseSeed(0);
  frameRate(30);
}

void draw() {
  
  float ca = map(mouseX / ((float) width), 0, 1, -1, 0.5);
  float cb = map(mouseY / ((float) height), 0, 1, -0.8, 1);
  float t = millis() / 1000.0;
  float k = map(sin(log(t)), -1, 1, 0.3, 1); 
  ca = k * sin(log(t) * 2);
  cb = k * cos(log(t) * 2);
  
  float scale =  0.5 * max(0, log(t));
  
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float za = map(((float) x) / width, 0, 1, -1, 1);
      float zb = map(((float) y) / height, 0, 1, -1, 1);
      za /= scale;
      zb /= scale;
      // za *= scale;
      // zb *= scale;
      
      int i = 0;
      int maxI = 100;
      while (i < maxI && sqrt(za * za + zb * zb) < 3) {
        i += 1;
        za += ca;
        zb += cb;
        float zr = za * za - zb * zb;
        zb = 2 * za * zb;
        za = zr;
      }
      
      int c;
      if (i < maxI) {
        c = color(i / ((float) maxI) * 255);
      } else {
        c = color(255);
      }
      
      
      pixels[x + y * width] = c;
    }
  }
  updatePixels();
  
  //fill(255, 0, 0);
  //text("C: " + ca + " + " + cb, 12, 12); 
  
  saveFrame("frames/#####.tif");
}