class Line {
  float x1, y1, x2, y2;

  Line(float x1, float y1, float x2, float y2) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
  }

  void update() {
  }

  void draw() {
    stroke(0);
    line(this.x1, this.y1, this.x2, this.y2);
  }
}

class P {
  PVector p, v;
  
  P() {
    p = new PVector(random(width), random(height));
    v = PVector.random2D();
  }
  
  void update() {
    p.add(v);
    v.mult(0.9);
  }
  
  void draw() {
    
  }
}

P player = null;
ArrayList<Line> lines = new ArrayList<Line>();
ArrayList<PVector> lights = new ArrayList<PVector>();

void setup() {
  size(640, 640);
  player = new P();
  frameRate(60);
  background(0);
  for (int i = 0; i < 10; i++) {
    lines.add(new Line(random(width), random(height), random(width), random(height)));
  }
}

void ray(Line lastLine, PVector start, PVector dir, float i, int reflections) { 
  if (reflections > 100) {
    fill(0);
    text("refs: " + reflections, 25, 25);
    return;
  }
  float x = start.x;
  float y = start.y;
  float vx = dir.x;
  float vy = dir.y;

  float earliest_collision = -1;
  Line line = null;
  for (int li = 0; li < lines.size(); li++) {
    Line l = lines.get(li);
    if (l == lastLine) {
      continue;
    }
    float dx = l.x2 - l.x1;
    float dy = l.y2 - l.y1;
    float denum = (dy - vy/vx * dx);
    
    if (denum == 0) {
      return;
    }
    
    float t = (y - l.y1 + vy/vx * (l.x1 - x)) / denum;
    // t = (mouseY + vy / vx * (l.x1 - mouseX)) / (dy - vy / vx * dx)
    float p = (l.x1 + dx * t - x) / vx;

    if (p > 0 && t > 0 && t < 1) {
      if (earliest_collision == -1 || p < earliest_collision) {
        earliest_collision = p;
        line = l;
      }
    }
  }

  if (earliest_collision == -1) {
    fill(0);
    text("refs: " + reflections, 25, 25);
    earliest_collision = max(width, height);
  } else {
    PVector newDir = dir.copy();
    PVector l = new PVector(line.x2 - line.x1, line.y2 - line.y1);
    l.normalize();
    PVector bounce = PVector.sub(newDir, PVector.mult(l, l.dot(newDir)));
    newDir.sub(bounce);
    newDir.sub(bounce);
    newDir.normalize();
    float offset = 0;
    ray(line, new PVector(x + vx * (earliest_collision) + newDir.x * offset, y + vy * (earliest_collision)+ newDir.y * offset), newDir, i, reflections + 1);
  }

  float offset = 0;//min(earliest_collision, noise(abs(i - 0.5) * 1, millis() * 0.001) * 10 + 30);
  stroke(255, 255.0 / reflections);
  line(x + vx * offset, y + vy * offset, x + vx * (earliest_collision), y + vy * (earliest_collision));
}

void update() {
  for (Line l : lines) {
    l.update();
  }
  float f = 0.5;
  PVector force = new PVector();
  if (keyPressed) {
    switch (key) {
      case 'w': force.add(0, -f); break;
      case 'a': force.add(-f, 0); break;
      case 's': force.add(0, f); break;
      case 'd': force.add(f, 0); break;
    }
  }
  player.v.add(force);
  player.update();
}

void mouseClicked() {
  lights.add(new PVector(mouseX, mouseY));
}

void draw() {
  fill(0);
  rect(0, 0, width, height);

  update();

  strokeWeight(1.1);
  stroke(0);
  int n = 50;
  for (int i = 0; i < n; i++) {
    float p = ((float) i) / n;
    float t = millis() * 0.00001;
    float x = cos(p * 2 * PI + t);//noise(abs(p - 0.5) * 1, t) * 5);
    float y = sin(p * 2 * PI + t);//noise(abs(p - 0.5) * 1, t) * 5);
    for (int li = 0; li < lights.size(); li++) {
      ray(null, lights.get(li), new PVector(x, y), p, 0);
    }
    ray(null, player.p, new PVector(x, y), p, 0);
  }
  for (Line l : lines) {
    l.draw();
  }
}