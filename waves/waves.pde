class P {
  PVector p, v;
  float w;

  P() {
    this.p = new PVector(random(width), random(height));
    this.v = new PVector();
    this.w = 0.0;
  }
  
  void update() {
    w = w + (1 - w) * 0.001;
    p.add(v);    
  }
}

ArrayList<P> ps = new ArrayList<P>();
void setup() {
  size(640, 640);

  for (int i = 0; i < 1; i++) {
    P p = new P();
    p.w = 1;
    ps.add(p);
  }

  ellipseMode(CENTER);
}

void update() {
  if (frameCount / 50 > ps.size() * ps.size() && ps.size() < 4) {
    ps.add(new P());
  }
  for (int i = 0; i < ps.size(); i++) {
    P a = ps.get(i);
    for (int j = i + 1; j < ps.size(); j++) {
      P b = ps.get(j);
      PVector d = b.p.copy();
      d.sub(a.p);
      float mag = d.mag();
      d.div(mag);
      d.mult((width / 4 - mag) * -0.01);
      a.v.add(d);
      b.v.sub(d);
    }
  }

  for (P p: ps) {
    p.update();
  }
}

void draw() {
  update();
  ps.get(0).p.set(width / 2, height / 2);
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float val = 0;
      
      for (P p: ps) {
        float d = dist(p.p.x, p.p.y, x, y);
        float wave = (sin(d / width * PI * 2 * 25 - frameCount * 0.5) + 1) / 2;
        val += (wave + 0.1) / (d * d * 0.0001) * p.w;
      }

      int c;
      if (val > 0.999) {
        c = color(255);
      } else {
        c = color(0);
      }
      pixels[x + y * width] = c;
    }
  }

  updatePixels();
}