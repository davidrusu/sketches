PVector shift = new PVector();
float mouseR = 25;

class MarkovProcess {
  MarkovProcess(int num_states) {
    this.matrix = new float[num_states][num_states];
  }
}

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

int next_node_id = 0;

class Peer {
  Node node;
  int prevHeartbeat;
  int nodeStateTimestamp;

  Peer(Node node) {
    this.node = node;
    this.prevHeartbeat = millis();
  }

  Peer copy() {
    Peer copy = new Peer(node);
    copy.prevHeartbeat = prevHeartbeat;
    return copy;
  }

  void receivedHeartbeat(Node node, int timestamp) {
    this.node = node;
    prevHeartbeat = millis();
    this.nodeStateTimestamp = timestamp;
  }

  PVector predictPos() {
    return node.pos;
    //float dt = millis() - prevHeartbeat;
    //return PVector.add(node.pos, PVector.mult(node.vel, dt));
  }

  boolean isStale() {
    return millis() - prevHeartbeat > 6000;
  }
}

class Node {
  int id;
  PVector pos, vel;
  float r = 5;
  HashMap<Integer, Peer> peers = new HashMap<Integer, Peer>();
  int lastHeartbeat = millis();
  int lastPacketTime = millis();

  Node() {
    id = next_node_id++;
    pos = new PVector(random(width), random(height));
    vel = PVector.random2D();
    vel.mult(0.01);
  }

  Node copy() {
    Node copy = new Node();
    copy.id = id;
    copy.pos = pos.copy();
    copy.vel = vel.copy();
    for (Peer p : peers.values()) {
      copy.peers.put(p.node.id, p.copy());
    }
    return copy;
  }

  void receivedPacket(Packet p) {
    lastPacketTime = millis();
    if (peers.containsKey(p.source.id)) {
      peers.get(p.source.id).receivedHeartbeat(p.source, 0);
    } else if (peers.size() < 5) {
      peers.put(p.source.id, new Peer(p.source));


      for (Peer peerOfPeer : p.source.peers.values()) {
        if (peers.containsKey(peerOfPeer.node.id) || peerOfPeer.node.id == id || peers.size() > 3) {
          continue;
        }
        PVector dir = PVector.sub(peerOfPeer.node.pos, pos);
        dir.normalize();
        emitPacket(this, pos.copy(), dir, millis() + 10000);
      }
    }


    float d = PVector.dist(p.source.pos, pos);

    PVector f = p.source.pos.copy();
    f.sub(pos);
    f.normalize();
    f.mult((50 - d) * -0.0001);
    vel.add(f);
  }

  boolean isLonely() {
    return millis() - lastPacketTime > 10000;
  }

  void update(float dt) {
    pos.add(PVector.mult(vel, dt));
    vel.mult(0.99);

    if (random(1) < 0.001) {
      emitPacket(this, pos.copy(), PVector.random2D(), millis() + 10000);
    }

    ArrayList<Peer> stalePeers = new ArrayList<Peer>();

    for (Peer p : peers.values()) {
      if (p.isStale()) {
        stalePeers.add(p);
      }
    }
    for (Peer p : stalePeers) {
      peers.remove(p.node.id);
    }

    if (millis() - lastHeartbeat > 5000) {
      lastHeartbeat = millis();
      for (Peer p : peers.values()) {
        PVector dir = PVector.sub(p.predictPos(), pos);
        dir.normalize();
        emitPacket(this, pos.copy(), dir, millis() + 10000);
      }
    }
  }

  void draw() {
    stroke(0, 150);

    for (Peer p : peers.values()) {
      PVector pPos = p.predictPos();
      line(pos.x, pos.y, pPos.x, pPos.y);
    }

    fill(255);
    stroke(0);
    ellipse(pos.x, pos.y, r * 2, r * 2);
  }
}


ArrayList<Node> nodes = new ArrayList<Node>();
ArrayList<Packet> packets = new ArrayList<Packet>();
ArrayList<Packet> packetsToSend = new ArrayList<Packet>();

void emitPacket(Node source, PVector pos, PVector dir, int expires) {
  packetsToSend.add(new Packet(source.copy(), pos, PVector.mult(dir, 0.1), expires));
}

void setup() {
  size(640, 640);

  for (int i = 0; i < 100; i++) {
    nodes.add(new Node());
  }
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
  if (millis() / 5000 > nodes.size()) {
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