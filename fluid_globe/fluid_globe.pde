ArrayList<Point> ps = new ArrayList<Point>();
PVector gravity = new PVector(0, 0);
float air = 0.99;

class Point {
  PVector pos, vel;

  Point() {
    reset();
  }

  void reset() {
    pos = new PVector(random(0, width), random(0, height));
    vel = new PVector(0, 0);
  }

  void update() {
    vel.add(gravity);
    
    float border = 100;
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
    
    borderF = new PVector(width/2, height/2);
    borderF.sub(pos.x, pos.y);
    float d = borderF.mag();
    
    if (d > 150) {
      borderF.div(150);
      borderF.mult(1);
      vel.add(borderF);
    }
    
    vel.mult(air);
    pos.add(vel);
  }

  void draw() {
    fill(57, 48, 74);
    ellipse(pos.x, pos.y, 5, 5);
  }
}

float noiseScale = 0.02;

void setup() {
  size(640, 640, P2D);
  frameRate(60);
  for (int i = 0; i < 1000; i++) {
    ps.add(new Point());
  }
  ellipseMode(CENTER);
}

void update() {
  gravity = new PVector(map(mouseX, 0, width, -1, 1),
                        map(mouseY, 0, height, -1, 1));
  gravity.mult(1);
  for (int i = 0; i < ps.size(); i++) {
    Point a = ps.get(i);

    for (int j = i + 1; j < ps.size(); j++) {
      Point b = ps.get(j);
      PVector delta = b.pos.copy();
      delta.sub(a.pos);
      if (delta.mag() < 1) {
        delta = PVector.random2D();
        delta.mult(2);
      }
      float d = max(1, delta.mag());

      if (d < 15) {
        delta.div(d);
        float f = -1 / (d * d) * 20;
        delta.mult(f);
        delta.limit(1);
        a.vel.add(delta);
        b.vel.sub(delta);
        
        float resist = 0.01;
        PVector proj = delta.copy();
        proj.normalize();
        proj.mult(a.vel.dot(delta) / delta.mag());
        proj.mult(resist);
        a.vel.sub(proj);
        
        proj = delta.copy();
        proj.normalize();
        proj.mult(b.vel.dot(delta) / delta.mag());
        proj.mult(resist);
        b.vel.sub(proj);
      }
    }
  }
  for (Point p : ps) {
    PVector mouseDelta = new PVector(mouseX, mouseY);
    mouseDelta.sub(p.pos);

    float mouseD = max(1, mouseDelta.mag());

    mouseDelta.div(mouseD);
    float mouseF = -1/(mouseD * mouseD) * 1000;
    mouseDelta.mult(mouseF);

    mouseDelta.limit(2);

    p.update();
  }
}

PVector calcVectorAt(float x, float y) {
  float angle = map(noise(x * noiseScale, y * noiseScale), 0, 1, 0, 4*PI);
  return new PVector(cos(angle), sin(angle));
}

void draw() {
  update();
  background(176, 169, 144);

  stroke(99, 92, 81);
  noFill();
  int n = 7;
  for (int i = 0; i < n + 1; i++) {
    float p = ((float) i) / n;
    p *= p;
    p = 1 - p;
    ellipse(width / 2, height / 2, 300 * p, 300);
    ellipse(width / 2, height / 2, 300, 300 * p);
  }
  
  fill(32, 32, 48);
  noStroke();
  ellipse(mouseX, mouseY, 10, 10);
  for (Point p : ps) {
    p.draw();
  }
  //saveFrame("frames/#####.tif");
}