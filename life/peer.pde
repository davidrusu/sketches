class Peer {
  Node node;
  int prevHeartbeat;
  int nodeStateTimestamp;
  boolean enemy = false;
  
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