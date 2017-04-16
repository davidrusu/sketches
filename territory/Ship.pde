class Ship {
  float x, y, vx, vy, angle;
  float speed = 1;

  Ship(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void forward() {
    this.vx += cos(angle) * speed;
    this.vy += sin(angle) * speed;
  }

  void back() {
    this.vx -= cos(angle) * speed;
    this.vy -= sin(angle) * speed;
  }

  void update() {
    x += vx;
    y += vy;
    vx *= 0.99;
    vy *= 0.99;
  }

  void draw() {
    translate(x, y);
    rotate(angle);
    float size = 5;
    fill(255);
    triangle(-size * 3 / 2, size, -size * 3 / 2, -size, size * 3 / 2, 0);
    rotate(-angle);
    translate(-x, -y);
  }
}