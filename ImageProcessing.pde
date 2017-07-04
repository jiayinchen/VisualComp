//import gab.opencv.*;
import java.util.*;

PImage img;

PImage img1;
PImage img2;
PImage img3;
PImage img4;

int RESIZE_BY = 2; // size of original image is divided by RESIZE_BY
int nLines = 6;

boolean quadFound = false;
int countQuadFounds = 0;
boolean vrbse = false;
List<PVector> sortedCorners;

//HScrollbar thresholdBar;
//HScrollbar thresholdBar2;

BlobDetection bd = new BlobDetection();
int thr = 128;
float h1 = 128;
float h2 = 128;

class ImageProcessing extends PApplet {
  private PVector angles = new PVector();
  
  PVector getRotation() {
    return angles;
  }
  
  void settings() {
    size(2400/RESIZE_BY, 600/RESIZE_BY);
  }
  void setup() {
    opencv = new OpenCV(this, 100, 100);
  
    cam = new Movie(this, "/Users/JiaYin/Desktop/cs-an/Milestone3/testvideo.avi");
    cam.loop();
    
    //noLoop();
    //thresholdBar = new HScrollbar(0, 580, 800, 20);
    //thresholdBar2 = new HScrollbar(0, 550, 800, 20);
    //img = loadImage("board1.jpg");
    //img = loadImage("board2.jpg");
    //img = loadImage("board3.jpg");
    //img = loadImage("board4.jpg");
  }
  
  void draw() {
    if (videoRunning) {
      if (cam.available()) {
        cam.read();
      }
      img = cam.get(); 

      //background(color(128, 128, 128));
      
      int resizedHeight = img.height / RESIZE_BY;
      int resizedWidth = img.width / RESIZE_BY;
      //image(img, 0, 0);
      //thresholdBar.display();
      //thresholdBar.update();
      //thresholdBar2.display();
      //thresholdBar2.update();
      //thr = (int)(thresholdBar.getPos()*255);
      //h1 = thresholdBar.getPos()*255;
      //h2 = thresholdBar2.getPos()*255;
      
      //Input image
      img1 = img.copy();
      img1.resize(resizedWidth, resizedHeight);
      image(img1, 0, 0);
      
      //Hue/brightness/saturation threshold
      img2 = img.copy();
      img2 = thresholdHSB(img2, 100, 140, 150, 255, 50, 155);
      
      //Blob detection
      img3 = bd.findConnectedComponents(img2, false);
      
      //Blurring
      img4 = gaussian(img3);
      
      //Edge detection
      img4 = scharr(img4);
      
      //Brightness
      thresholdB(img4, 50, 255);
      
      //Hough
      List<PVector> lines = hough(img4, 4);
    
      QuadGraph quadgraph = new QuadGraph();
      quadgraph.build(lines, img.width, img.height);
      float pArea = 50;
      int min_quad_area = (int) (img.width * img.height / pArea);
      int max_quad_area = (int) (img.width * img.height * (pArea-1)/pArea); //<>//
      
      List<PVector> bestQuad = quadgraph.findBestQuad(lines, img.width, img.height,
        max_quad_area, min_quad_area, vrbse);
      
      // prepare homogeneous coordinates
      ArrayList<PVector> homogCorners = new ArrayList<PVector>();
      // draw the corners
      stroke(0, 0, 0);
      fill(255, 128, 0);
      for(PVector corner : bestQuad){
        //println("bestQuad: " + corner.x + ", " + corner.y);
        ellipse(corner.x, corner.y, 10/RESIZE_BY, 10/RESIZE_BY);
        homogCorners.add(homogeneous2DPoint(corner));
      }
      
      img3.resize(resizedWidth, resizedHeight);
      image(img3, resizedWidth, 0);
      
      img4.resize(resizedWidth,resizedHeight);
      image(img4, 2*resizedWidth, 0);
      if (vrbse) {
        println(quadFound);
        println(countQuadFounds);
      }
      if (quadFound)
        sortedCorners = quadgraph.sortCorners(homogCorners);
    
      if (sortedCorners != null) {
        //fill(50, 250, 50, 180);
        //quad(output.get(0).x, output.get(0).y, output.get(1).x, output.get(1).y, output.get(2).x, output.get(2).y, output.get(3).x, output.get(3).y);
    
        TwoDThreeD twoDthreeD = new TwoDThreeD(resizedWidth, resizedHeight, 10);
        angles = twoDthreeD.get3DRotations(sortedCorners);
        /*if (angles.x > PI/2.0) angles.x = angles.x - PI;
        else if (angles.x < -PI/.20) angles.x = angles.x + PI;*/
        //println(degrees(angles.x) + ", " + degrees(angles.y) + ", " + degrees(angles.z));
        //println(angles.x + ", " + angles.y + ", " + angles.z);
    //board1: 172.77026, 14.172758, 3.2176714
    //board2: 169.43741, -10.920801, 15.4895
    //board3: -157.33789, 4.912211, 0.9941543
    //board4: -160.41501, -44.646854, -5.328407
      
      }
      quadFound = false;
    }
  }
  
  PImage threshold(PImage img, int threshold) {
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      if (brightness(img.pixels[i]) > threshold) {
        result.pixels[i] = color(0, 0, 0);
      } else {
        result.pixels[i] = color(255, 255, 255);
      }
    }
    return result;
  }
  PImage huehue(PImage img) {
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      if (hue(img.pixels[i]) >= h1 && hue(img.pixels[i]) <= h2) {
        result.pixels[i] = color(hue(img.pixels[i]));
      }
    }
    return result;
  }
  PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      if (hue(img.pixels[i]) >= minH && hue(img.pixels[i]) <= maxH) {
        if (saturation(img.pixels[i]) >= minS && saturation(img.pixels[i]) <= maxS) {
          if (brightness(img.pixels[i]) >= minB && brightness(img.pixels[i]) <= maxB) {
            result.pixels[i] = color(255, 255, 255);
          }
        }
      }
    }
    return result;
  }
  boolean imagesEqual(PImage img1, PImage img2) {
    if (img1.width != img2.width || img1.height != img2.height)
      return false;
    for (int i = 0; i < img1.width*img1.height; i++)
      //assuming that all the three channels have the same value
      if (red(img1.pixels[i]) != red(img2.pixels[i]))
        return false;
    return true;
  }
  
  PImage convolute(PImage img) { //wrong, use alg from gaussian (could fix, but we're not using this function anymore)
    float[][] kernel = { { 0, 0, 0}, 
      { 0, 2, 0 }, 
      { 0, 0, 0 }};
    float normFactor = 1.f;
    int N = 3;
    PImage result = createImage(img.width, img.height, ALPHA);
    for (int i = 0; i < img.width * img.height; i++) {
      float p = 0;
      for (int y = -N/2; y <= N/2; y++) {
        for (int x = -N/2; x <= N/2; x++) {
          int j = i+x + y*img.width;
          if (j >= 0 && j < img.width*img.height) {
            p+= brightness(img.pixels[j])*kernel[y+N/2][x+N/2];
          }
        }
      }
      p/= normFactor;
      result.pixels[i] = (color(p));
    }
    return result;
  }
  
  PImage gaussian(PImage img) {
    float[][] kernel = { { 9, 12, 9}, 
      { 12, 15, 12 }, 
      { 9, 12, 9 }};
    float normFactor = 99.f;
    int N = 3;
    PImage result = createImage(img.width, img.height, RGB);
    for (int xx = 1; xx < img.width-1; xx++) {
      for (int yy = 1; yy < img.height-1; yy++) { 
        float p = 0;
        for (int y = -N/2; y <= N/2; y++) {
          for (int x = -N/2; x <= N/2; x++) {
            int j = (xx+img.width*yy)+x + y*img.width;
            p+= brightness(img.pixels[j])*kernel[y+N/2][x+N/2];
          }
        }
        p/= normFactor;
        result.pixels[xx+yy*img.width] = (color(p));
      }
    }
    return result;
  }
  
  PImage scharr(PImage img) {
    float[][] vKernel = {
      {  3, 0, -3  }, 
      { 10, 0, -10 }, 
      {  3, 0, -3  } };
    float[][] hKernel = {
      {  3, 10, 3 }, 
      {  0, 0, 0 }, 
      { -3, -10, -3 } };
    int N = 3;
    PImage result = createImage(img.width, img.height, ALPHA);
    // clear the image
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }
    float max=0;
    float[] buffer = new float[img.width * img.height];
    for (int xx = 1; xx < img.width-1; xx++) {
      for (int yy = 1; yy < img.height-1; yy++) { 
        float sum_h = 0;
        float sum_v = 0;
        for (int y = -N/2; y <= N/2; y++) {
          for (int x = -N/2; x <= N/2; x++) {
            int j = (xx+img.width*yy)+x + y*img.width;
            sum_h+= brightness(img.pixels[j])*hKernel[y+N/2][x+N/2];
            sum_v+= brightness(img.pixels[j])*vKernel[y+N/2][x+N/2];
          }
        }
        float sum=sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        if (sum > max) max = sum;
        buffer[xx+img.width*yy] = sum;
      }
    }
  
  
    for (int y = 2; y < img.height - 2; y++) {
      // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) {
        // Skip left and right
        int val=(int) ((buffer[y * img.width + x] / max)*255);
        result.pixels[y * img.width + x]=color(val);
      }
    }
    return result;
  }
  
  void thresholdB(PImage image, float min, float max) {
    image.loadPixels();
  
    float h = 0;
    for (int i = 0; i < image.width * image.height; i++) {
      h = brightness(image.pixels[i]);
      if (h < min || h > max) {
        image.pixels[i] = color(0);
      }else{
        image.pixels[i] = image.pixels[i]; 
      }
    }
  }
  
  PVector homogeneous2DPoint (PVector p) {
    PVector result = new PVector(p.x, p.y, 1.0);
    return result;
  }
}