class Packet {
  PVector pos, vel;
  Node source;
  float r = 2;
  int expires;

  Packet(Node source, PVector pos, PVector vel, int expires) {
    this.pos = pos;
    this.vel = vel;
    this.source = source;
    this.expires = expires;
  }

  void update(float dt) {
    pos.add(PVector.mult(vel, dt));
    vel.mult(1);
  }

  void draw() {
    fill(255, 0, 0);
    stroke(0, 100);
    ellipse(pos.x, pos.y, r * 2, r * 2);
  }
}