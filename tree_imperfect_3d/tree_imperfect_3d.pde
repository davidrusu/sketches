void setup() {
  size(500, 500, P3D);
}

void tree(float x, float y, float z, float length, float angle, float angleZ) {
  if (length < 2) {
    if (random(1) < 0.01) {
    translate(x, y, z);
    //sphere(3);
    translate(-x, -y, -z);
    }
    return;
  } 
  float ny = y - length * sin(angle);
  float nx = x + length * cos(angle);
  float nz = z + length * sin(angleZ);
  strokeWeight(length / 5);
  stroke(0);
  line(x, y, z, nx, ny, nz);
  float bias = PI/6 * (map(sin(millis()/3000.0), -1, 1, -1, 1)) * random(0, 1);
  float biasZ = PI/6 * (map(sin(millis()/3000.0), -1, 1, -1, 1)) * random(0, 1);
  float dangle = PI/4 * map(sin(millis() / 2000.0), -1, 1, -1, 1) * random(1);
  float dangle2 = PI/4 * map(sin(millis() / 1000.0 + PI / 2), -1, 1, 0, 1) * random(1);
  //float dangleZ = PI/4 * map(sin(millis() / 1000.0), -1, 1, -1, 1) * random(1);
  //float dangleZ2 = PI/4 * map(sin(millis() / 5000.0 + PI / 2), -1, 1, -1, 1) * random(1);
  float dangleZ = PI/4 * random(-1, 1);
  float dangleZ2 = PI/4 * random(-1, 1);
  //float dangleZ2 = PI/2 * random(-1, 1);
  float new_l = length * random(0.6, 0.8);
  tree(nx, ny, nz, new_l, angle + dangle + bias, angleZ + dangleZ + biasZ);
  tree(nx, ny, nz, new_l, angle - dangle2 + bias, angleZ - dangleZ2 + biasZ);
}

void draw() {
  fill(255);
  rect(0, 0, width, height);
  //background(255, 100);
  randomSeed(0);
  translate(width / 2, height/2 + 100, 100);
  //rotateX(map(mouseX, 0, width, 0, 2 * PI));
  rotateX(-PI/6);
  rotateY(millis() / 10000.0);
  //rotateZ(map(mouseY, 0, height, 2*PI, -2*PI));
  //rotateY(map(mouseY, 0, height, 0, 2 * PI));
  //for (int i = 0;  i < 10; i++) {
  tree(0, 0, 0, 60, PI* 0.5, 0);
  //}
  
  saveFrame("frames/#####.tif");
}