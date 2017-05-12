class Datum {
  int c;
  float t;
  public Datum(int c, float t) {
    this.c = c;
    this.t = t;
  }
}

int[] colors = {color(117, 95, 248), 
                color(77, 122, 225),
                color(47, 188, 237),
                color(35, 216, 168),
                color(250, 204, 79),
                color(251, 86, 85) };

ArrayList<Datum> data = new ArrayList<Datum>();
float timeOffset = 0;
float targetTimeOffset = 0;

float memory = 7;
float hw, hh, r;
void setup() {
  size(500, 500, P2D);
  randomSeed(0);
  hw = width / 2;
  hh = height / 2;
  r = hw;
}

void mousePressed() {
  float dx = hw - mouseX;
  float dy = hh - mouseY;
  float dist = min(r, sqrt(dx*dx + dy * dy)) + (r / memory) / 2;
  targetTimeOffset += (dist / r) * memory - memory / 2;
}

Datum getDatum(float time) {
  for (int i = data.size() - 1; i >= 0; i--) {
     if (data.get(i).t <= time) {
       return data.get(i);
     }
  }
  return null;
}

int randColor() {
  return colors[(int) random(0, colors.length)];
  //return color(random(r * 255), random(g * 255), random(b * 255));
}

void draw() {
  //mousePressed();
  float speed = 1/1.0;
  float curTime = speed * millis() / 1000.0;
  timeOffset += (-(memory * mouseY) / height - timeOffset) * 0.1;
  curTime = timeOffset + curTime;
  if (curTime > random(0.5, 2) * data.size()) {
    data.add(new Datum((int) randColor(), curTime));
  }
  background(255);
  int n = (int)(memory * 10);
  float startAngle = curTime;
  float px = r * cos(startAngle);
  float py = r * sin(startAngle);
  for (int i = 0; i < n; i++) {
    float p = 1 - (float) i / n;
    float angle = p * memory * 2 * PI;
    float x = r * p * cos(startAngle + angle);
    float y = r * p * sin(startAngle + angle);
    Datum datum = getDatum((curTime - ((1-p) * memory)));
    if (datum != null) {
      fill(datum.c);
      stroke(datum.c);
    } else {
      fill(255);
      stroke(255);
    }
    strokeWeight(1);
    triangle(hw + px, hh + py, hw + x, hh + y, hw, hh);
    stroke(255);
    strokeWeight(5);
    line(hw + px, hh + py, hw + x, hh + y);
    px = x;
    py = y;
  }
  fill(0);
  text("current time: " + curTime, 25, 25);
}