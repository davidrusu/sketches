int I = 50;
int shiftX = 0;
int shiftY = 0;
float scale = 1;

void handleKeyPressed() {
  if (keyCode == UP) {
    I++;
  } else if (keyCode == DOWN) {
    I--;
  } else if (key == 'z') {
    scale *= 1.01;
  } else if (key == 'x') {
    scale *= 1 - .01;
  }
}
class Complex {
  float a = 0;
  float b = 0;
  public Complex(float a, float b) {
    this.a = a;
    this.b = b;
  }
  
  void set(float a, float b) {
    this.a = a;
    this.b = b;
  }
  
  void square() {
    float a2 = a * a - b * b;
    float b2 = 2 * a * b;
    this.a = a2;
    this.b = b2;
  }
  
  void add(Complex c) {
    this.a += c.a;
    this.b += c.b;
  }
  
  float abs() {
    return a * a + b * b;
  }
}

void setup() {
  size(displayWidth, displayHeight);
}

void draw() {
  handleKeyPressed();
   Complex c = new Complex(((float)mouseX - width / 2) / width, ((float)mouseY - height / 2) / height);
   float s = 3.0 / min(width, height) * scale;
   Complex z = new Complex(0, 0);
   loadPixels();
   for (int x= 0; x < width; x++) {
     for (int y = 0; y < height; y++) {
       z.set((x - width / 2) * s, (y - height / 2) * s);
       boolean allIn = true;
       
       for (int i = 0; i < I; i++) {
         if (z.abs() >= 4) {
           allIn = false;
           pixels[y * width + x] = color(int((1 * i % I) * 255.0 / I), int((2 * i % I) * 255.0 / I), int((3*i % I) * 255.0 / I));
           break;
         }
         z.square();
         z.add(c);
       }
       if (allIn) {
         stroke(0);
         pixels[y * width + x] = color(0);
       }
     }
   }
   updatePixels();
   fill(255);
   text(c.a + " + " + c.b + "i", 25, 25);
}