class TerritoryPoint {
  float x, y, vx, vy;
  float health = 100;
  float decay = 1;
  
  TerritoryPoint(float x, float y, float vx, float vy) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
  }

  void update() {
    x += vx;
    y += vy;
    vx *= 0.9;
    vy *= 0.9;
    health -= decay;
    //float attract = 0.001;
    //vx += (ship.x - x) * attract;
    //vy += (ship.y - y) * attract;
  }

  boolean isDead() {
    return health <= 0;
  }
  void draw() {
    fill(255);
    ellipse(x, y, 2, 2);
  }

  String toString() {
    return "Point: x="+x+" y="+y;
  }
}