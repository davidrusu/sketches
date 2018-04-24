int next_node_id = 0;
class MarkovChain {
  float[][][] matrix;
  int state = 0;

  MarkovChain(int states, int events) {
    assert states >= 1;
    assert events >= 1;
    randomInit(states, events);
  }

  void randomInit(int states, int events) {
    matrix = new float[events][states][states];
    for (int e = 0; e < events; e++) {
      for (int curr_state = 0; curr_state < states; curr_state++) {
        for (int next_state = 0; next_state < states; next_state++) {
          matrix[e][curr_state][next_state] = random(1);
        }
      }
    }
    norm();
  }

  void norm() {
    for (int e = 0; e < matrix.length; e++) {
      for (int curr_state = 0; curr_state < matrix[e].length; curr_state++) {
        float sum = 0;
        for (int next_state = 0; next_state < matrix[e][curr_state].length; next_state++) {
          sum += matrix[e][curr_state][next_state];
        }
        for (int next_state = 0; next_state < matrix[e][curr_state].length; next_state++) {
          matrix[e][curr_state][next_state] /= sum;
        }
      }
    }
  }

  int nextState(int event) {
    float p = random(1);

    float cumulative_p = 0;
    int next_state = -1;
    while (p > cumulative_p && next_state < matrix[event][state].length) {
      next_state += 1;
      cumulative_p += matrix[event][state][next_state];
    }

    this.state = next_state;
    return this.state;
  }
}

class Node {
  int id;
  PVector pos, vel;
  float r = 10;
  HashMap<Integer, Peer> peers = new HashMap<Integer, Peer>();
  int lastHeartbeat = millis();
  int lastPacketTime = millis();
  MarkovChain mc;

  Node() {
    id = next_node_id++;
    pos = new PVector(random(width), random(height));
    vel = PVector.random2D();
    vel.mult(0.01);
    mc = new MarkovChain(10, 4);
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
  
  void applyForce(float fx, float fy) {
    this.vel.add(fx, fy);
  }

  void stepMarkovProcess() {
    int state = mc.nextState(0);
    float force_k = 0.005;
    switch (state) {
      case 0: applyForce(force_k, 0); break;
      case 1: applyForce(-force_k, 0); break;
      case 2: applyForce(0, force_k); break;
      case 3: applyForce(0, -force_k); break;
      default:
      
    }
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
    if (random(1) > .9) {
      stepMarkovProcess();
    }
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

    if (millis() - lastHeartbeat > 1000) {
      lastHeartbeat = millis();
      for (Peer p : peers.values()) {
        if (random(1) > 0.9) {
          p.enemy = true;
        }
        if (p.enemy) {
          continue;
        }
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