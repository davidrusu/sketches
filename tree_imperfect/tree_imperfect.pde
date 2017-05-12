void setup() {
  size(500, 500);
}

void tree(float x, float y, float length, float angle) {
  if (length < 2) {
    return;
  } 
  float ny = y - length * sin(angle);
  float nx = x + length * cos(angle);
  stroke(0);
  line(x, y, nx, ny);
  float dangle = PI/2 * ((float) mouseX / width) * random(0, 1);
  float bias = PI/2 * ((float) mouseY / height - 0.5);
  float new_l = length * random(0.5, 0.9);
  tree(nx, ny, new_l, angle + dangle + bias);
  tree(nx, ny, new_l, angle - dangle + bias);
}

void draw() {
  background(255);
  randomSeed(0);
  tree(width / 2, height, height / 5, PI/2);
}