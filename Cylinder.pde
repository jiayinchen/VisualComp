class Cylinder {
  float cylinderHeight = 50.0;
  int cylinderResolution = 30;
  PVector location;
  float groundHeight =cylinderHeight+boxHeight/2.0;
  PShape openCylinder = new PShape();
  PShape surface = new PShape();
  float angle;
  float[] x;
  float[] y;

  Cylinder(float xx, float yy) {
    location = new PVector(xx, -groundHeight, yy);
    x = new float[cylinderResolution + 1];
    y = new float[cylinderResolution + 1];
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    surface = createShape();
    surface.beginShape(TRIANGLE_FAN);
    surface.vertex(0, 0, 0);
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i], 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
      surface.vertex(x[i], y[i], 0);
    }
    openCylinder.endShape();
    surface.endShape();
  }
  
  public PVector getPosition(){
    return location;
  }

  void display() {
    
    pushMatrix();
    if (!shiftMode) {
      translate(location.x, location.y, location.z);
      rotateX(-PI/2);
      openCylinder.setStroke(false);
      surface.setStroke(false);
    } else {
      translate(location.x, location.z, cylinderHeight);
      openCylinder.setStroke(true);
      surface.setStroke(true);
      rotateX(-PI);
    }
    openCylinder.setFill(color(150,150,50));
    surface.setFill(color(150,150,50));
    shape(openCylinder);
    shape(surface);
    popMatrix();
  }
}