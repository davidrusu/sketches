PShader shader;

void setup() {
  size(640, 640, P2D);
  noStroke();
   
  // This GLSL code shows how to use shaders from 
  // shadertoy in Processing with minimal changes.
  shader = loadShader("shader.glsl");
  shader.set("resolution", float(width), float(height));   
}

void draw() {
  background(0);
    
  shader.set("time", millis() / 1000.0);
  shader(shader); 
  rect(0, 0, width, height);
  
  
  fill(255);
  rect(100,100, 100, 50);
  fill(0, 0, 255);
  text("fps: " + frameRate, 12, 12);
}