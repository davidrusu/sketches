PVector shift = new PVector();
float mouseR = 25;

ArrayList<Node> nodes = new ArrayList<Node>();
ArrayList<Packet> packets = new ArrayList<Packet>();
ArrayList<Packet> packetsToSend = new ArrayList<Packet>();

void emitPacket(Node source, PVector pos, PVector dir, int expires) {
  packetsToSend.add(new Packet(source.copy(), pos, PVector.mult(dir, 0.5), expires));
}

void setup() {
  size(640, 640);

  //for (int i = 0; i < 100; i++) {
  //  nodes.add(new Node());
  //}
  ellipseMode(CENTER);
}

int lastFrameTime = millis();
void update() {
  float dt = millis() - lastFrameTime;
  lastFrameTime = millis();

  for (Packet p : packetsToSend) {
    packets.add(p);
  }
  packetsToSend.clear();
  if (millis() / 5000  + (-millis() / 10000. + 100)  > nodes.size()) {
    nodes.add(new Node());
  }
  ArrayList<Node> nsToRemove = new ArrayList<Node>();
  for (Node n : nodes) {
    if (n.isLonely()) {
      nsToRemove.add(n);
    }
  }

  for (Node n : nsToRemove) {
    nodes.remove(n);
  }

  for (Node n : nodes) {
    n.update(dt);
  }
  for (Packet p : packets) {
    p.update(dt);
  }

  ArrayList<Packet> psToRemove = new ArrayList<Packet>();

  for (Packet p : packets) {
    if (PVector.dist(p.pos, getMouse()) < mouseR) {
      psToRemove.add(p);
      continue;
    }
    if (millis() > p.expires) {
      psToRemove.add(p);
      continue;
    }
    for (Node n : nodes) {
      if (p.source.id != n.id && PVector.dist(p.pos, n.pos) < p.r + n.r) {
        n.receivedPacket(p);
        psToRemove.add(p);
        break;
      }
    }
  }

  for (Packet p : psToRemove) {
    packets.remove(p);
  }
}

PVector getMouse() {
  return new PVector(mouseX + shift.x - width / 2, mouseY + shift.y - height / 2);
}

void draw() {

  background(255);

  PVector avg = new PVector();
  PVector upLeft = new PVector();
  PVector bottomRight = new PVector();

  for (Node n : nodes) {
    avg.add(n.pos);
    //if (n.pos.x < upLeft.x) {
  }

  avg.div(max(1, nodes.size()));
  float pShift = 0.1;
  shift.set(shift.x * (1-pShift) + avg.x * pShift, shift.y * (1-pShift) + avg.y * pShift);
  translate(width/2, height/2);
  float scale = 1;

  scale(scale);
  translate(-shift.x, -shift.y);

  update();

  for (Node n : nodes) {
    n.draw();
  }
  for (Packet p : packets) {
    p.draw();
  }

  noFill();
  PVector mouse = getMouse();
  ellipse(mouse.x, mouse.y, mouseR * 2, mouseR * 2);
}