int steps = 1;

void setup() {
  size(300, 300, P2D);
  noiseDetail(7);
}

void keyPressed() {
  if (keyCode == UP) {
    steps += 1;
  } else {
    steps = max(0, steps - 1);
  }
}
void setP(int x, int y, int c) {
  pixels[y * width + x] = c;
}
float fbm(float x, float y) {
  float scale = 0.005;
  return noise(x * scale, y * scale, frameCount * 0.01);
}

float fix(int n, float x, float y) {
  if (n <= 0) {
    return fbm(x, y);
  }
  float v = fbm(x, y);
  float r = v * 2 * PI;
  float v2x = cos(r) * v;//0;//random(-1, 1);//cos(r);
  float v2y = sin(r) * v;//0;//random(-1, 1);
  float amt = 5;
  v2x *= amt;
  v2y *= amt;
  float v2 = fbm(x + v2x, y + v2y);
  v2 *= amt;
  v *= amt;
  return fix(n-1, 
    (v + fbm(v2x, 0)) * width, 
    (v2 + fbm(v2y, 0)) * height);
}

void f(int x, int y) {
  float v = fix(steps, x, y);
  color from = color(8, 45, 88);
  color to = color(247, 68, 39);
  setP(x, y, lerpColor(from, to, v));
}

void draw() {
  loadPixels();

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      f(x, y);
    }
  }
  updatePixels();
  //saveFrame("frames/#####.tiff");
}