import gab.opencv.*;
import java.util.*;
import processing.video.*;

OpenCV opencv;
ImageProcessing imgproc;
Movie cam;

float rx = 0;
float rz = 0;
float speed = 1.0;
float boxHeight = 10;
float boxWidth = 275;
Sphere sphere;
boolean shiftMode = false;
boolean videoRunning = true;
ArrayList<Cylinder> cylinders = new ArrayList();
float cylinderBaseSize = 25.0;
PGraphics bckgrnd, topView, scoreboard, barChart;
double score = 0;
double scoreChange =0;
HScrollbar hscrollbar;
ArrayList<Double> scores = new ArrayList();
int chartWidth = 3;
boolean isOutside=false;


void settings() {
  size(1280, 600, P3D);
}
void setup() {
  opencv = new OpenCV(this, 100, 100);
  
  imgproc = new ImageProcessing();
  String[] args = { "Image processing window"};
  PApplet.runSketch(args, imgproc);
  
  sphere = new Sphere();
  bckgrnd = createGraphics(width, height, P2D);
  topView = createGraphics(100, 100, P2D);
  scoreboard = createGraphics(200, 100, P2D);
  barChart = createGraphics(width-300, 80, P2D);
  hscrollbar = new HScrollbar (300, height-20, width-300, 20);
}

void draw() {  
  camera();
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  background(200);
  text("X-Rotation: " + (double)round(degrees(rz)*100)/100 + "   Y-Rotation: " + (double)round(degrees(rx)*100)/100 + "   Speed: " + (double)round(speed*100)/100, 10, 10);   
  pushMatrix();
  translate(width/2, height/2, 0);
  if (!shiftMode) {
    noStroke();
    
    if (videoRunning) {
      PVector rot = imgproc.getRotation();
      rx = rot.x;
      rz = rot.y;
    }
    
    rotateX(-rx);
    rotateZ(rz);
    fill(100,255,100);
    box(boxWidth, boxHeight, boxWidth);
    fill(100, 255, 255);
    sphere.update();
    sphere.checkEdges();
    sphere.checkCylinderCollision();
    sphere.display();
  } else {
    stroke(1);
    fill(100,255,100);
    box(boxWidth, boxWidth, boxHeight);
    fill(100, 255, 255);
    sphere.display();
  }

  for (int i = 0; i < cylinders.size(); i++) {
    cylinders.get(i).display();
  }
  popMatrix();
  drawBckgrnd();
  image(bckgrnd,0,0);
  drawTopView();
  image(topView,0,height-100);
  drawScoreboard();
  image(scoreboard,100,height-100);
  drawBarChart();
  image(barChart,300,height-100);
  hscrollbar.update();
  hscrollbar.display();
  
  chartWidth = 3 + (int)(hscrollbar.getPos()*8);
}

void drawBckgrnd(){
  bckgrnd.beginDraw();
  fill(25,225,200);
  bckgrnd.rect(0, height-100, width, 100);
  bckgrnd.endDraw();
}

void drawTopView(){
  topView.beginDraw();
  //topView.stroke(1);
  topView.background(0,0,0,0);
  topView.fill(100,255,100);
  //board
  topView.rect(5,5,90,90);
  //sphere
  float ratio = boxWidth/90.0;
  topView.fill(100, 255, 255);
  topView.ellipse(5 +90.0/2 +sphere.location.x/ratio, 5 +90.0/2 +sphere.location.z/ratio, 2*sphere.radius/ratio, 2*sphere.radius/ratio);
  //cylinders
  topView.fill(150,150,50);
  for (int i = 0; i < cylinders.size(); i++) {
    topView.ellipse(5 +90.0/2 +cylinders.get(i).location.x/ratio,5 +90.0/2 +cylinders.get(i).location.z/ratio,2*cylinderBaseSize/ratio,2*cylinderBaseSize/ratio);
  }
  topView.endDraw();
}

void drawScoreboard(){
  scoreboard.beginDraw();
  scoreboard.textSize(12);
  scoreboard.fill(0);
  scoreboard.background(0,0,0,0);
  scoreboard.text("Total Score:", 10, 20);
  scoreboard.text("" + ((int)(score*100))/100.0, 10, 30); 
  scoreboard.text("Velocity:", 10, 50);
  scoreboard.text("" + ((int)(sphere.v*100))/100.0, 10, 60);
  scoreboard.text("Last Score:", 10, 80); 
  scoreboard.text("" + ((int)(scoreChange*100))/100.0, 10, 90);
  scoreboard.endDraw();
}

void drawBarChart(){
  barChart.beginDraw();
  barChart.background(0,0,0,0);
  barChart.fill(0);
  for(int i = 0; i < scores.size(); i++){
    if(scores.get(i) <0){
      int r = (int)Math.floor(-scores.get(i)/5);
      barChart.fill(255);
      for(int j = 0; j < r; j++){
        barChart.rect(1+(i*chartWidth),76-(j*5),chartWidth-2,3);
      }
    }else{
      int r = (int)Math.floor(scores.get(i)/5);
      barChart.fill(0);
      for(int j = 0; j < r; j++){
        barChart.rect(1+(i*chartWidth),76-(j*5),chartWidth-2,3);
      }
    }
  }
  barChart.endDraw();
}

void mouseDragged() {
  if (!shiftMode && (mouseY < height - 20) && !videoRunning) {
    
    rx -= (pmouseY - mouseY)*speed/500.0;
    rz -= (pmouseX - mouseX)*speed/500.0;
    
    if (rx > PI/3) rx = PI/3;
    if (rx < -PI/3) rx = -PI/3;
    if (rz > PI/3) rz = PI/3;
    if (rz < -PI/3) rz = -PI/3;
  }
}
void mouseWheel(MouseEvent event) {
  if (!shiftMode) {
    speed -= event.getCount()/50.0;
    if (speed < 0.1) speed = 0.1;
    if (speed > 3) speed = 3;
    println("Speed = " + speed);
  }
}
void mouseClicked() {
  if (shiftMode) {
    if(Math.abs(mouseX-width/2) < boxWidth/2 - cylinderBaseSize && Math.abs(mouseY-height/2) < boxWidth/2 - cylinderBaseSize)
      cylinders.add(new Cylinder(mouseX-width/2, mouseY-height/2));
  }
}
void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shiftMode = true;
    }
  }
}
void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shiftMode = false;
    }
  }
}