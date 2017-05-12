int dimW = 500;
int dimH = 500;
ArrayList<TerritoryPoint> territory = new ArrayList<TerritoryPoint>();
Ship ship;
ArrayList<PVector> emmiters = new ArrayList<PVector>();
boolean debug = true;

void setup() {
  size(displayWidth, displayHeight);
  ship = new Ship(width/2, height/2);
  randomSeed(0);
  ellipseMode(CENTER);
}

void emitTerritoryPoint(float x, float y) {
  float speed = random(5, 10);
  float vx = random(-1, 1);
  float vy = random(-1, 1);
  float v = sqrt(vx * vx + vy * vy);
  vx /= v;
  vy /= v;
  territory.add(new TerritoryPoint(x, y, vx*speed, vy*speed));
}

void update() {
  ship.update();
  //emitTerritoryPoint(mouseX, mouseY);
    for (PVector e : emmiters) {
  //if (random(1) < 0.3) {
      emitTerritoryPoint(e.x, e.y);
    //}
  }
  if (millis() / 100 % 2 == 0) {
    emitTerritoryPoint(ship.x, ship.y);
  }
  ArrayList<TerritoryPoint> toRemove = new ArrayList<TerritoryPoint>();
  for (TerritoryPoint p : territory) {
    p.update();
    if (p.isDead()) {
      toRemove.add(p);
    }
  }
  for (TerritoryPoint p : toRemove) {
    territory.remove(p);
  }
}

void keyPressed() {
  if (keyCode == UP) {
    ship.forward();
  } else if (keyCode == DOWN) {
    ship.back();
  } else if (key == ' ') {
    emmiters.add(new PVector(ship.x, ship.y));
  }
}

void mousePressed() {
  emmiters.add(new PVector(mouseX, mouseY));
}

void draw() {
  update();
  background(0);
  float dx = mouseX-ship.x;
  float dy = mouseY - ship.y;
  if (dx != 0) {
    ship.angle = atan(dy / dx) + (min(0, dx) / abs(dx)) * PI;
  }
  for (TerritoryPoint p : territory) {
    //p.draw();
  }
  for (ArrayList<TerritoryPoint> hull : concaveHulls((ArrayList<TerritoryPoint>) territory.clone(), 0.02)) {
    //shape(hullToPShape(hull), 0, 0);
  }
  fill(100, 100, 100);
  for (PVector v : emmiters) {
    ellipse(v.x, v.y, 10, 10);
  }
  
  ship.draw();
  fill(255, 0, 0);
  text("FPS: " + frameRate, 25, 25);
  text("territory points: " + territory.size(), 25, 50);
}