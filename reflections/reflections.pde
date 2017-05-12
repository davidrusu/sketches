import processing.video.*;

import gab.opencv.*;

class Line {
  PVector p1, p2;

  Line(PVector p1, PVector p2) {
    this.p1 = p1;
    this.p2 = p2;
  }
  
  void draw() {
    stroke(255, 0, 0);
    line(p1.x, p1.y, p2.x, p2.y);
  }
}

class P {
  PVector p, v;
  
  P() {
    p = new PVector(random(width), random(height));
    v = PVector.random2D();
  }
  
  void update() {
    p.add(v);
    v.mult(0.9);
  }
  
  void draw() {
  }
}

P player = null;
ArrayList<Line> lines = new ArrayList<Line>();
ArrayList<PVector> lights = new ArrayList<PVector>();

Capture cam;
OpenCV opencv;

void setup() {
  size(1280, 720);
  player = new P();
  background(0);
  for (int i = 0; i < 10; i++) {
    lines.add(new Line(new PVector(random(width), random(height)),
                       new PVector(random(width), random(height))));
  }
  
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
  opencv = new OpenCV(this, width, height);
}

void ray(Line sourceLine, PVector o, PVector v, int reflections) {
  if (reflections > 10) {
    println("exhausted reflections");
    return;
  }

  float earliest_collision = -1;
  Line line = null;
  for (Line l: lines) {
    if (l == sourceLine) {
      continue;
    }
    PVector d = PVector.sub(l.p2, l.p1);
    float denum = (d.y - v.y/v.x * d.x);
    
    if (denum == 0) {
      //println("denum is 0");
      continue;
    }
    
    // math is magic
    float t = (o.y - l.p1.y + v.y/v.x * (l.p1.x - o.x)) / denum;
    float p = (l.p1.x + d.x * t - o.x) / v.x;

    if (p > 0 && t > 0 && t < 1) {
      if (earliest_collision == -1 || p < earliest_collision) {
        earliest_collision = p;
        line = l;
      }
    }
  }

  if (earliest_collision == -1) {
    //println("exited screen");
    earliest_collision = sqrt(width * width + height * height);
  } else {
    PVector newDir = v.copy();
    PVector l = PVector.sub(line.p2, line.p1);
    l.normalize();
    PVector bounce = PVector.sub(newDir, PVector.mult(l, l.dot(newDir)));
    bounce.mult(2);
    newDir.sub(bounce);
    newDir.normalize();
    ray(line, new PVector(o.x + v.x * (earliest_collision), o.y + v.y * (earliest_collision)), newDir, reflections + 1);
  }

  stroke(255, 255.0 / reflections);
  line(o.x, o.y, o.x + v.x * (earliest_collision), o.y + v.y * (earliest_collision));
}

void update() {
  float f = 0.5;
  PVector force = new PVector();
  if (keyPressed) {
    switch (key) {
      case 'w': force.add(0, -f); break;
      case 'a': force.add(-f, 0); break;
      case 's': force.add(0, f); break;
      case 'd': force.add(f, 0); break;
    }
  }
  player.v.add(force);
  player.update();
}

void mouseClicked() {
  lights.add(new PVector(mouseX, mouseY));
}

void calcLines() {
  if (cam.available() == true) {
    cam.read();
  }
  if (cam.width <= 0 || cam.height <= 0) {
    return;
  }
  opencv.loadImage(cam);
  opencv.gray();
  opencv.blur(5);
  opencv.threshold(50);
  opencv.erode();
  opencv.flip(1);
  
  ArrayList<Contour> contours = opencv.findContours();
  if (contours.size() <= 2) return;
  //println("contours " + contours.size());
  lines.clear();
  for (Contour contour : contours) {
    contour.setPolygonApproximationFactor(5);
    ArrayList<PVector> points = contour.getPolygonApproximation().getPoints();
    for (int i = 0; i < points.size(); i++) {
      PVector a = points.get(i);
      PVector b = points.get((i + 1) % points.size());
      lines.add(new Line(a, b));
    }
  }
}

void draw() {
  fill(0);
  rect(0, 0, width, height);

  update();
  
  calcLines();
  
  strokeWeight(1.1);
  stroke(0);
  int n = 50;
  player.p.set(mouseX, mouseY);
  for (int i = 0; i < n; i++) {
    float p = ((float) i) / n;
    float t = millis() * 0.00001;
    float x = cos(p * 2 * PI + t);
    float y = sin(p * 2 * PI + t);
    for (int li = 0; li < lights.size(); li++) {
      ray(null, lights.get(li), new PVector(x, y), 0);
    }
    ray(null, player.p, new PVector(x, y), 0);
  }
  //for (Line l : lines) {
  //  l.draw();
  //}
  
}