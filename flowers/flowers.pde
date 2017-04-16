void setup() {
  size(640, 640);
}

void draw() {
  float t = (frameCount + 500) * 0.3;
  float slowt = t / 100;
  background(255);
  translate(width / 2, height / 2);
  float n = 5000;
  float px = 0;
  float py = 0;
  
  for (int i = 0; i < n; i++) {
    float p = i / n;
    float osc = sin(p * 2 * PI * map(sin(slowt - PI/4), -1, 1, 0, 500) + t);
    float r = height * 0.5 * p + osc * p * 15;

    float loops = 30;
    float nx = sin(p * 2 * PI * loops) * r;
    float ny = cos(p * 2 * PI * loops) * r;

    strokeWeight(map(osc, -1, 1, 1, 5) * p);
    stroke(0);
    line(px, py, nx, ny);
    px = nx;
    py = ny;
  }
  
  //saveFrame("frames/#####.tif");
}