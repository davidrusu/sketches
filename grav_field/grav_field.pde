ArrayList<Point> ps = new ArrayList<Point>();
float air = 0.999;
float shiftX = 0;
float shiftY = 0;

class Point {
  PVector pos, vel;
  float mass;
  
  Point() {
    reset();
  }

  void reset() {
    pos = new PVector(random(0, width), random(0, height));
    vel = new PVector(0, 0);
    mass = 100;
  }

  void update() {
    float border = 50;
    float borderK = 0.0001;
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

    vel.mult(air);
    pos.add(vel);
  }

  void draw() {
    fill(57, 48, 74);
    noStroke();
    ellipse(pos.x + shiftX, pos.y + shiftY, 5, 5);
  }
}

void setup() {
  size(640, 640, P2D);
  frameRate(60);

  for (int i = 0; i < 5; i++) {
    ps.add(new Point());
  }

  ellipseMode(CENTER);
}

void update() {
  float t = (frameCount) * 0.001 * PI;
  //ps.get(0).pos.set(mouseX, mouseY);
  //ps.get(0).vel.set(0,0);
  for (int i = 0; i < ps.size(); i++) {
    Point p = ps.get(i);
    PVector force = calcForceAt(p.pos.x, p.pos.y);
    //force.div(p.mass);
    p.vel.add(force);
  }
  
  for (Point p: ps) {
    p.update();
  }
}
PVector netForce = new PVector();
PVector calcForceAt(float x, float y) {
  float nx = 0;
  float ny = 0;
  for (int i = 0; i < ps.size(); i++) {
    Point p = ps.get(i);
    float dx = x - p.pos.x;
    float dy = y - p.pos.y;
    
    float dSq = dx * dx + dy * dy;
    if (dSq == 0) {
      continue;
    }
    if (dSq < 1) {
      dSq = 1;
    }
  
    float f = (-1 / dSq) * p.mass;
    float d = sqrt(dSq);
    dx *= f/d;
    dy *= f/d;
    nx += dx;
    ny += dy;
  }
  netForce.set(nx, ny);
  netForce.limit(2);
  return netForce;
}

void drawGravField() {
  noStroke();
  int gridSize = 300;
  float cellW = ((float) width) / gridSize;
  float cellH = ((float) width) / gridSize; 
  loadPixels();
  for (int x = 0; x < gridSize; x++) {
    for (int y = 0; y < gridSize; y++) {
      float f = calcForceAt(x * cellW + cellW / 2 - shiftX,
                            y * cellH + cellH / 2 - shiftY).mag();
      f = sqrt(f);
      float limit = 1.0;
      int upperXs = min((int)((x + 1) * cellW), width);
      int upperYs = min((int)((y + 1) * cellH), height);
      int c = color((int) map(min(f, limit), 0, limit, 0, 255));
      for (int xs = (int) (x * cellW); xs < upperXs; xs++) {
        for (int ys = (int) (y * cellH); ys < upperYs; ys++) {
          pixels[xs + width * ys] = c;
        }
      }
      // fill();
      // rect(x*cellW, y*cellW, , (y + 1) * cellH);
    }
  } 
  updatePixels();
}

void draw() {
  update();
  
  float nShiftX = 0, nShiftY = 0;
  for (Point p: ps) {
    nShiftX += p.pos.x;
    nShiftY += p.pos.y;
  }
  nShiftX /= ps.size();
  nShiftY /= ps.size();
  nShiftX *= -1;
  nShiftY *= -1;
  nShiftX += width / 2;
  nShiftY += height / 2;
  float tween = 0.1;
  shiftX = shiftX * (1 - tween) + nShiftX * tween;
  shiftY = shiftY * (1 - tween) + nShiftY * tween; 
  background(176, 169, 144);

  fill(32, 32, 48);
  noStroke();
  //ellipse(mouseX, mouseY, 10, 10);
  
  drawGravField();
  fill(255,0,0);
  ellipse(width/2 - (shiftX - nShiftX), height/2 - (shiftY - nShiftY), 3, 3);
  fill(0,255,0);
  ellipse(width / 2, height / 2, 3, 3);

  for (Point p : ps) {
    p.draw();
  }

  //saveFrame("frames/#####.tif");
}