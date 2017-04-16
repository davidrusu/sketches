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
  float dangle = PI/2 * ((float) mouseX / width);
  float bias = PI/2 * ((float) mouseY / height - 0.5);
  tree(nx, ny, length * 0.7, angle + dangle + bias);
  tree(nx, ny, length * 0.7, angle - dangle + bias);
}

void draw() {
  background(255);
  tree(width / 2, height, height / 5, PI/2);
}