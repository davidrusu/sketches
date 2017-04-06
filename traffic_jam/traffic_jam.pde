float air = 0.5;
float mouseR = 25;
class P {
  PVector p, v;
  PVector c;
  float r;
  float speed;
  
  P(float x, float y) {
    p = new PVector(x, y);
    v = new PVector();
    c = new PVector(random(width), random(height));
    r = random(width / 12, width / 6);
    speed = random(10, 50) / r;
  }
  
  void update() {
    PVector target = p.copy();
    target.sub(c);
    target.normalize();
    target.mult(r);
    target.add(c);
    
    PVector force = target.copy();
    force.sub(p);
    float d = force.mag();
    force.normalize();
    force.mult(0.5 * d);
    v.add(force);
    
    PVector angular_force = target.copy();
    angular_force.sub(c);
    angular_force.set(-angular_force.y, angular_force.x);
    angular_force.normalize();
    angular_force.mult(speed);
    v.add(angular_force);
    
    p.add(v);
    v.mult(air);
  }
  
  void draw() {
    stroke(255, 255);
    strokeWeight(1);
    noFill();
    float angle = PVector.sub(p, c).heading();
    arc(c.x, c.y, r * 2, r * 2, angle - PI/24 - speed * PI/48, angle);
    
    noStroke();
    fill(255);
  } 
}

ArrayList<P> ps = new ArrayList<P>();

void setup() {
  size(640, 640);
  ellipseMode(CENTER);
  strokeCap(SQUARE);
  for (int i = 0; i < 500; i++) {
    ps.add(new P(random(width), random(height)));
  }
}

void update() {
  for (P p: ps) {
    p.update();
  }
  
  for (int i = 0; i < ps.size(); i++) {
    for (int j = i + 1; j < ps.size(); j++) {
      P a = ps.get(i);
      P b = ps.get(j);
      
      PVector delta = PVector.sub(b.p, a.p);
      float d = max(1, delta.mag());
      if (d > 50) {
        continue;
      }
      delta.normalize();
      delta.mult(-10 / d);
      a.v.add(delta);
      b.v.sub(delta);
    }
  }
  
  for (int i = 0; i < ps.size(); i++) {
    P a = ps.get(i);
    PVector mouse = new PVector(mouseX, mouseY);
    
    PVector delta = PVector.sub(mouse, a.p);
    float d = max(1, delta.mag());
    if (d > mouseR + 10) {
      continue;
    }
    delta.normalize();
    delta.mult(-max(0, (d - mouseR)) * 0.1);
    a.v.add(delta);
  }
}

void draw() {
  update();
  
  fill(0);
  rect(0, 0, width, height);
  stroke(255);
  fill(150);
  strokeWeight(1);
  ellipse(mouseX, mouseY, mouseR * 2, mouseR * 2);
  for (P p: ps) {
    p.draw();
  }
}