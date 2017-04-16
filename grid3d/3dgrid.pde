float bounds = 640;

class Particle {
  PVector pos, vel;
  
  Particle() {
    pos = new PVector(random(-bounds, bounds), random(-bounds, bounds), random(-bounds, bounds));
    vel = new PVector(0, 0, 0);
  }
  
  void update() {
    float air = 0.95; 
    PVector f = calcVectorAt(pos.x, pos.y, pos.y);
    float k = 0.5;
    f.mult(k);
    vel.add(f);
    
    pos.add(vel);
    vel.mult(air);
    
    if (pos.x < 0) {
      pos.x = width;
    }
    if (pos.x > width) {
      pos.x = 0;
    }
    
    if (pos.y < 0) {
      pos.y = height;
    }
    if (pos.y > height) {
      pos.y = 0;
    }
  }
  
  void draw() {
    noStroke();
    fill(0);
    translate(pos.x, pos.y, pos.z);
    sphere(3);
    translate(-pos.x, -pos.y, -pos.z);
  }
}

ArrayList<Particle> ps = new ArrayList<Particle>();
float noiseScale = 0.02;
int gridSize = 20;

void setup() {
  size(640, 640, P3D);
  
  for (int i = 0; i < 500; i++) {
    ps.add(new Particle());
  }
}

void update() {
  for (Particle p: ps) {
    p.update();
  }
  
  for (int i = 0; i < ps.size(); i++) {
    Particle a = ps.get(i);
    for (int j = 0; j < ps.size(); j++) {
      Particle b = ps.get(j);
      PVector delta = b.pos.copy();
      delta.sub(a.pos);
      
      float d = max(1, delta.mag());
      
      if (d < 10) {
        delta.div(d);
        float f = -1/(d * d);
        delta.mult(f);
        a.vel.add(delta);
        b.vel.sub(delta);
      }
    }
  }
}

PVector calcVectorAt(float x, float y, float z) {
  float t = millis() / 5000.0; 
  float angle = map(noise(x * noiseScale, y * noiseScale, t), 0, 1, 0, 2*PI);
  float anglez = map(noise(z, t), 0, 1, 0, 2 * PI);
  return new PVector(cos(angle), sin(angle), sin(anglez));
}

void draw() {
  //update();
  background(255);
  translate(width/2, height/2);
  rotateX(millis() / 100000.0);
  rotateY(millis() / 200000.0);
  rotateZ(millis() / 300000.0);
  translate(-width/2, -height/2);
  float cellW = ((float) bounds) / gridSize;
  
  float scale = cellW / 10;
  sphereDetail(1);
  strokeWeight(3);
  for (int x = -gridSize; x < gridSize; x++) {
    for (int y = -gridSize; y < gridSize; y++) {
      for (int z = -gridSize; z < gridSize; z++) {
        PVector v = calcVectorAt(x * cellW, y * cellW, z * cellW);
        //point(x * cellW, y * cellW, z * cellW);
        
        stroke(0, map(z * cellW, -gridSize * cellW, gridSize * cellW, 0, 255));
        line(x * cellW, y * cellW, z * cellW, x * cellW + v.x * scale, y * cellW + v.y * scale, z * cellW + v.z * scale);
      }
    }
  }
  //for (Particle p: ps) {
  //  p.draw();
  //}
  //saveFrame("frames/#####.tif");
}