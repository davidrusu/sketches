import java.util.HashSet;

class Edge {
  int a, b;
  Edge(int a, int b) {
    this.a = a;
    this.b = b;
  }

  @Override
  public boolean equals(Object e) {
    Edge edge = (Edge) e;
    return edge.a == a && edge.b == b;
  }

  public int hashCode() {
    return a >> 16 | b;
  }
}

ArrayList<PVector> ps = new ArrayList<PVector>();
ArrayList<PVector> vs = new ArrayList<PVector>();
HashSet<Edge> es = new HashSet<Edge>();
float max_es;

void setup() {
  size(640, 640);
  reset();
  ellipseMode(CENTER);
}

void reset() {
  ps.clear();
  vs.clear();
  es.clear();
  int n = 500;
  for (int i = 0; i < n; i++) {
    ps.add(new PVector(random(width), random(height)));
    vs.add(new PVector());
  }

  max_es = ps.size() * 0.99;
  int n_es = 0;// (int) (ps.size() * 0.75);
  for (int i = 0; i < n_es; i++) {
    Edge e = makeEdge();
    if (e != null) {
      es.add(e);
    }
  }
}

boolean edgeExists(int a, int b) {
  return es.contains(new Edge(a, b));
}

Edge makeEdge() {
  int a, b, i = 0;
  int max_iter = 100;
  do {
    a = (int) random(ps.size());
    b = (int) random(ps.size());
    if (b < a) {
      int t = a;
      a = b;
      b = t;
    }
    i += 1;
  } while ( i < max_iter  && (a == b || edgeExists(a, b)));
  if (i == max_iter) {
    return null;
  }
  return new Edge(a, b);
}

void update() {
  float air = 0.95;
  float rest = 2;
  float k = 0.01;
  for (Edge e : es) {
    PVector a = ps.get(e.a);
    PVector b = ps.get(e.b);
    PVector delta = a.copy();
    delta.sub(b);
    float d = max(1, delta.mag());
    float f = (rest - d) * k;
    delta.mult(f / d);
    vs.get(e.a).add(delta);
    vs.get(e.b).sub(delta);
  }

  for (int i = 0; i < ps.size(); i++) {
    PVector a = ps.get(i);
    for (int j = i + 1; j < ps.size(); j++) {
      PVector b = ps.get(j);
      if (!edgeExists(i, j)) {
        PVector delta = a.copy();
        delta.sub(b);
        float d = max(1, delta.mag());
        float f = min(1, 1/d * 0.5);

        delta.mult(f / d);
        vs.get(i).add(delta);
        vs.get(j).sub(delta);
      }
    }
  }

  for (int i = 0; i < ps.size(); i++) {
    PVector a = ps.get(i);
    PVector delta = new PVector(width / 2, height / 2);
    delta.sub(a);
    float d = max(1, delta.mag());
    float f = d * 0.005;
    delta.mult(f / d);
    vs.get(i).add(delta);
  }
  
  for (int i = 0; i < ps.size(); i++) {
    ps.get(i).add(vs.get(i));
    vs.get(i).mult(air);
  }
}

void draw() {
  float upper = ps.size() * 0.05;
  if (random(1) < upper / max(upper, es.size())) {// && es.size() < max_es) {
    Edge e = makeEdge();
    if (e != null) {
      es.add(e);
    }
  }
  ArrayList<Edge> es_to_remove = new ArrayList<Edge>();
  
  for (Edge e: es) {
    float d = ps.get(e.a).dist(ps.get(e.b));
    float d_normed = map(min(d, 150), 0, 150, 0, 1);
    if (random(1) < d_normed * d_normed / 100.0) {
      es_to_remove.add(e);
    }
  }
  for (Edge e: es_to_remove) {
    es.remove(e);
  }
  if (keyPressed && key == ' ') {
    reset();
  }
  update();

  background(0);

  for (PVector p : ps) {
    fill(255);
    strokeWeight(0.5);
    stroke(255);
    noFill();
    ellipse(p.x, p.y, 3, 3);
  }

  for (Edge e : es) {
    float d = ps.get(e.a).dist(ps.get(e.b));
    //stroke(255, map(min(width/2, d), 0, width/2, 50, 255));
    stroke(255);
    strokeWeight(map(min(50, d), 0, 50, 1, 0.1));
    line(ps.get(e.a).x, ps.get(e.a).y, ps.get(e.b).x, ps.get(e.b).y);
  }
  //saveFrame("frames/#####.tif");
}