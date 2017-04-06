float air = 0.9;

class P {
  PVector pos, vel;

  P() {
    reset();
  }

  void reset() {
    pos = new PVector(random(width), random(height));
    vel = PVector.random2D();
  }

  void update() {
    pos.add(vel);
    vel.mult(air);
    float f = 1;
    float border = 10;
    float bounce = 0;

    if (pos.x < border) {
      vel.x += f;
    }
    if (pos.x > height - border) {
      vel.x -= f;
    }
    if (pos.y < border) {
      vel.y += f;
    }
    if (pos.y > height - border) {
      if (vel.y > 0) {
        vel.y *= -bounce;
      }
      pos.y = height - border;
    }
    if (pos.y < border) {
      if (vel.y < 0) {
        vel.y *= -bounce;
      }
      pos.y = border;
    }
  }

  void draw() {
    fill(0);
    noStroke();
    ellipse(pos.x, pos.y, 3, 3);
  }
}

class Blob {
  ArrayList<P> ps = new ArrayList<P>();

  Blob(int n) {
    for (int i = 0; i < n; i++) {
      ps.add(new P());
    }
  }

  void update() {
    float r = 10;

    for (int i = 0; i < ps.size(); i++) {
      P a = ps.get(i);
      int j = (i + 1) % ps.size();
      int jj = (i + 2) % ps.size();
      P b = ps.get(j);
      P c = ps.get(jj);

      PVector ab = b.pos.copy();
      ab.sub(a.pos);

      PVector bc = c.pos.copy();
      bc.sub(b.pos);

      float theta = PVector.angleBetween(ab, bc);

      float torqueMag = (PI - theta) / (bc.mag() + ab.mag()) * 1;
      PVector torque = new PVector(-bc.y, bc.x);
      torque.normalize();
      torque.mult(torqueMag);
      c.vel.add(torque);

      float rad = (1.0 / ps.size()) * 2 * PI;
      float secant = dist(sin(0) * r, cos(0)*r, sin(rad) * r, cos(rad) * r);
      float target = secant;
      float k = 0.5;
      PVector delta = b.pos.copy();
      delta.sub(a.pos);
      float d = delta.mag();
      float f = -(target - d) * k;
      delta.normalize();
      delta.mult(f);
      a.vel.add(delta);
      b.vel.sub(delta);

      strokeWeight(1);
      stroke(0, 0, 0);
      float torqueScale = 100;
      torque.limit(0.1);
      line(c.pos.x, c.pos.y, c.pos.x + torque.x * torqueScale, c.pos.y + torque.y * torqueScale);
    }

    for (P p : ps) {
      p.update();
    }
  }

  void draw() {
  }
}

ArrayList<Blob> bs = new ArrayList<Blob>();

void setup() {
  size(640, 640);
  ellipseMode(CENTER);
  for (int i = 0; i < 20; i ++) {
    bs.add(new Blob(50));
  }
}

void update() {
  for (int i = 0; i < bs.size(); i++) {
    Blob a = bs.get(i);
    for (int j = i; j < bs.size(); j++) {
      Blob b = bs.get(j);

      for (int ia = 0; ia < a.ps.size(); ia++) {
        P pa = a.ps.get(ia);
        for (int ib = 0; ib < b.ps.size(); ib++) {
          P pb = b.ps.get(ib);
          if (pa == pb) {
            continue;
          }
          PVector delta = pb.pos.copy();
          delta.sub(pa.pos);
          float d = max(1, delta.mag());
          float distThresh = 50;
          if (a == b) {
            distThresh = 10;
          }
          if (d < distThresh) {
            float f = -1 / (d * d) * 50;
            if (a == b) {
              f /= 50;
            }
            delta.normalize();
            delta.mult(f);
            pa.vel.add(delta);
            pb.vel.sub(delta);
          }
        }
      }
    }
  }
  for (Blob b : bs) {
    b.update();
  }

  if (mousePressed) {
    for (P p : bs.get(0).ps) {
      PVector delta = p.pos.copy();
      delta.sub(mouseX, mouseY);
      float d = max(1, delta.mag());
      float spread = 100;
      float f = -spread / sqrt(d*d + spread*spread); 
      delta.normalize();
      delta.mult(f);
      p.vel.add(delta);
    }
  }
}

void draw() {
  background(100);
  update();
  for (Blob b : bs) {
    b.draw();
  }

  fill(255, 0, 0);
  text("fps: " + frameRate, 25, 25);
}