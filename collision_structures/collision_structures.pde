class P {
  PVector p, v;
  float r = 2;
  int birth;
  
  P() {
    p = PVector.random2D();
    p.mult(sqrt(width * width + height * height) / 4);
    p.add(width/2, height/2);
    v = PVector.sub(new PVector(mouseX, mouseY), p);
    v.normalize();
    v.mult(2);
    birth = millis();
  }
  
  void update() {
    p.add(v);
  }
  
  void draw() {
    fill(0);
    noStroke();
    ellipse(p.x, p.y, r * 2, r * 2);
  }
}

ArrayList<P> ps = new ArrayList<P>();

void setup() {
  size(640, 640);
  ellipseMode(CENTER);
}

void update() {
  
  if (random(1) < 1) {
    ps.add(new P());
  }
  
  ArrayList<P> toRemove = new ArrayList<P>();
  
  for (P p: ps) {
    if (millis() - p.birth > 10000) {
      toRemove.add(p);
    }
  }
  
  for (P p: toRemove) {
    ps.remove(p);
  }
  
  for (P p: ps) {
    p.update();
  }
  
  for (int i = 0; i < ps.size(); i++) {
    for (int j = i + 1; j < ps.size(); j++) {
      P a = ps.get(i);
      P b = ps.get(j);
      if (a.p.dist(b.p) < a.r + b.r) {
        PVector av = a.v.copy();
        a.v.add(b.v);
        a.v.div(2);
        b.v.add(av);
        b.v.div(2);
        
        
        //PVector delta = b.p.copy();
        //delta.sub(a.p);
        //float d = delta.mag();
        //delta.normalize();
        //delta.mult(0.1);
        //a.v.sub(delta);
        //b.v.add(delta);
        
      }
    }
  }
}

void draw() {
  update();
  background(255);
  for (P p: ps) {
    p.draw();
  }
}