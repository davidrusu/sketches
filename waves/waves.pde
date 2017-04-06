ArrayList<PVector> vs = new ArrayList<PVector>();
ArrayList<PVector> vels = new ArrayList<PVector>();
ArrayList<Float> weights = new ArrayList<Float>();

void setup() {
  size(640, 640);
  
  for (int i = 0; i < 1; i++) {
    vs.add(new PVector(random(width), random(height)));
    vels.add(new PVector());
    weights.add(1.0);
  }
  
  ellipseMode(CENTER);
}

void update() {
  if (frameCount / 50 > vs.size() * vs.size() && vs.size() < 4) {
    println("blah");
    vs.add(new PVector(random(width), random(height)));
    vels.add(new PVector());
    weights.add(0.0);
  }
  for (int i = 0; i < vs.size(); i++) {
    for (int j = i + 1; j < vs.size(); j++) {
      PVector d = vs.get(j).copy();
      d.sub(vs.get(i));
      float mag = d.mag();
      d.div(mag);
      d.mult((width / 4 - mag) * -0.01);
      vels.get(i).add(d);
      vels.get(j).sub(d);
    }
  }
  
  for (int i = 0; i < vs.size(); i++) {
    float w = weights.get(i);
    weights.set(i, w + (1 - w) * 0.001);
    vs.get(i).add(vels.get(i));
    //vels.get(i).normalize();
    //vels.get(i).mult(1);
    //vels.get(i).mult(0.9);
  }
}

void draw() {
  update();
  vs.get(0).set(width / 2, height / 2);
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float val = 0;
      for (int z = 0; z < vs.size(); z++) {
        PVector v = vs.get(z);
        float d = dist(v.x, v.y, x, y);
        float wave = (sin(d / width * PI * 2 * 25 - frameCount * 0.5) + 1) / 2;
        val += (wave + 0.1) / (d * d * 0.0001) * weights.get(z);
      }
      //val = val / vs.size();
      
      int c = color(val * 255);
      if (val > 0.999) {
        c = color(255);
      } else {
        c = color(0);
      }
      pixels[x + y * width] = c;
    }
  }
  
  updatePixels();
  //for (PVector v: vs) {
  //  ellipse(v.x, v.y, 10, 10);
  //}
  
  saveFrame("######.tiff");
}