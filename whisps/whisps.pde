float speed = 0.2;
float force = 0.05;

class P {
  PVector pos, vel;
  
  P() {
    reset();
  }
  
  void reset() {
    pos = new PVector(random(width * 1.0/3, width*2.0/3), random(height));
    vel = PVector.random2D();
    vel.mult(speed);
  }
  
  void update() {
    float border = 300;
    float force = 0.01;
    if (pos.x - border < 0) {
      vel.x += force;
    }
    if (pos.x + border > width) {
      vel.x -= force;
    }
    if (pos.y - border < 0) {
      vel.y += force;
    }
    if (pos.y + border > height) {
      vel.y -= force;
    }
    
    vel.normalize();
    vel.mult(speed);
    pos.add(vel);
  }
  
  void draw() {
    fill(0);
    float offset = 0 / speed;
    float len = 10 / speed;
    line(pos.x + vel.x * offset,
         pos.y + vel.y * offset,
         pos.x + vel.x * offset + vel.x * len,
         pos.y + vel.y * offset + vel.y * len);
  }
}

ArrayList<P> ps = new ArrayList<P>();

void setup() {
  size(640, 640);
  ellipseMode(CENTER);
  for (int i = 0; i < 500; i++) {
    ps.add(new P());
  }
}

void update() {
  for (int i = 0; i < ps.size(); i++) {
    P a = ps.get(i);
    for (int j = i + 1; j < ps.size(); j++) {
      P b = ps.get(j);
      PVector delta = b.pos.copy();
      delta.sub(a.pos);
      float d = max(1, delta.mag());
      if (d < 50) {
        float f = -1 / d * force;
        delta.normalize();
        delta.mult(f);
        a.vel.add(delta);
        b.vel.sub(delta);
      }
    }
  }
  
  for (P p: ps) {
    p.update();
  }
}

void draw() {
  update();
  fill(255, 10);
  rect(0, 0, width, height);
  
  for (P p: ps) {
    p.draw();
  }
  //saveFrame("frames/####.tif");
}