ArrayList<Particle> ps = new ArrayList<Particle>();

class Particle {
  PVector pos, vel;

  Particle() {
    reset();
  }
  
  void reset() {
    pos = new PVector(random(0, width), random(0, height));
    vel = new PVector(0, 0);
  }

  void update() {
    float air = 0.85; 
    PVector f = calcVectorAt(pos.x, pos.y);
    float k = 0.1;
    f.mult(k);
    vel.add(f);

    float border = 200;
    float borderK = 0.001;
    PVector borderF = new PVector();
    if (pos.x < border) {
      borderF.x += border - pos.x;
    }
    if (pos.y < border) {
      borderF.y += border - pos.y;
    }
    if (width - pos.x < border) {
      borderF.x -= border - (width - pos.x);
    }
    if (height - pos.y < border) {
      borderF.y -= border - (height - pos.y);
    }
    
    borderF.mult(borderK);
    vel.add(borderF);
    
    pos.add(vel);
    vel.mult(air);
  }
}

float noiseScale = 0.02;

void setup() {
  size(640, 640);
  for (int i = 0; i < 200; i++) {
    ps.add(new Particle());
  }
}

void update() {
  for (Particle p : ps) {
    p.update();
  }

  for (int i = 0; i < ps.size(); i++) {
    Particle a = ps.get(i);
    for (int j = 0; j < ps.size(); j++) {
      Particle b = ps.get(j);
      PVector delta = b.pos.copy();
      delta.sub(a.pos);

      float d = max(1, delta.mag());

      if (d < 10) {
        delta.div(d);
        float f = -1/(d * d);
        delta.mult(f);
        a.vel.add(delta);
        b.vel.sub(delta);
      }
    }
  }
}

PVector calcVectorAt(float x, float y) {
  float angle = map(noise(x * noiseScale, y * noiseScale), 0, 1, 0, 4*PI);
  return new PVector(cos(angle), sin(angle));
}

void metaBalls() {
  loadPixels();
  if (frameCount == 900) {
    noLoop();
  }
  float thresh = map(min(900, frameCount), 0, 900, 0.9, 0.5);
  thresh *= thresh;
  thresh *= 2;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float weight = 0;
      for (Particle p: ps) {
        float d = max(1, dist(x, y, p.pos.x, p.pos.y)) ;
        weight += 1 / d;
      }
      if (weight > thresh) {
        pixels[x + y * width] = color(0);
      } else {
        pixels[x + y * width] = color(255);
      }
    }
  }
  updatePixels();
}

void draw() {
  update();

  metaBalls();
  //saveFrame("frames/#####.tif");
}