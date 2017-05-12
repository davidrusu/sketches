float bounds = 640;
ArrayList<PVector> blockers = new ArrayList<PVector>();

class Particle {
  PVector pos, vel;
  int c;

  Particle() {
    reset();
  }

  void reset() {
    pos = new PVector(random(0, width), random(0, height));
    vel = new PVector(0, 0);
    c = calcColorAt(pos.x, pos.y);
  }

  void update() {
    float air = 0.85; 
    PVector f = calcVectorAt(pos.x, pos.y);
    float k = 0.1;
    f.mult(k);
    vel.add(f);

    pos.add(vel);
    vel.mult(air);

    if (pos.x < 0 || pos.x > width || pos.y < 0 || pos.y > height) {
      reset();
    }
    draw();
  }

  void draw() {
    stroke(c);
    point(pos.x, pos.y);
  }
}

ArrayList<Particle> ps = new ArrayList<Particle>();
float noiseScale = 0.02;
int gridSize = 50;

void setup() {
  size(640, 640, P2D);
  background(255);
  for (int i = 0; i < 1000; i++) {
    ps.add(new Particle());
  }

  for (int i = 0; i < 1; i++) {
    blockers.add(new PVector(random(width), random(height)));
  }
  ellipseMode(CENTER);
}

void update() {
  for (Particle p : ps) {
    p.update();
  }

  for (int i = 0; i < ps.size(); i++) {
    for (PVector b : blockers) {
      Particle a = ps.get(i);
      PVector delta = b.copy();
      delta.sub(a.pos);

      float d = max(1, delta.mag());

      if (d < 100000) {
        delta.div(d);
        float f = -1/(d * d) * 100;
        delta.mult(f);
        a.vel.add(delta);
      }
    }
  }
}

int calcColorAt(float x, float y) {
  float fuzz = 100;
  float r = dist(x, y, 0, 0) + random(fuzz);
  float g = dist(x, y, width, 0) + random(fuzz);
  float b = dist(x, y, width, height) + random(fuzz);

  float total = r + g + b;
  r = r / total * 255;
  g = g / total * 255;
  b = b / total * 255;

  return color(r, g, b, 100);
}
PVector calcVectorAt(float x, float y) {
  float t = 0; //millis() / 10000.0; 
  float angle = map(noise(x * noiseScale, y * noiseScale, t), 0, 1, 0, 4*PI);
  return new PVector(cos(angle), sin(angle));
}

void draw() {
  for (int i = 0; i < 10; i++) {
    update();
  }
  float cellW = ((float) bounds) / gridSize;
}