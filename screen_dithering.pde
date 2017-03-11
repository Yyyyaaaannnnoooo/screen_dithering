import java.awt.Robot;
import java.awt.Rectangle;
import java.awt.AWTException;
import controlP5.*;

ControlP5 controlP5;
boolean showGUI = false;
Slider[] sliders;

PImage img, screenshot;
int level = 1, count = 0;
float num = 0, fac = 16;
void setup() {
  size(400, 400, JAVA2D);
  noStroke();
  noSmooth();
  img = loadImage("1.jpg");
  setupGUI();
  //cp5 = new ControlP5(this);
  ////ControlGroup ctrl = cp5.addGroup("menu", 15, 25, 35);
  ////ctrl.setColorLabel(color(255));
  ////ctrl.close();
  //cp5.addSlider("fac")
  //  .setPosition(10, 10)
  //  .setSize(200, 20)
  //  .setRange(0.001, 20)
  //  .setValue(16)
  //  ;
}

void draw() {  
  screenshot();
  dither(screenshot, fac, level);
  drawGUI();
}

void keyPressed() {
  switch(key) {
    case('s'):
    String date = new java.text.SimpleDateFormat("yyyy_MM_dd_kkmmss").format(new java.util.Date ());
    saveFrame("dithering"+date+".jpg");
    case('d'):
    //background(0);
    //dither(img, img3, fac, level);
  }
  if (key=='m' || key=='M') {
    showGUI = controlP5.getGroup("menu").isOpen();
    showGUI = !showGUI;
  }
  if (showGUI) controlP5.getGroup("menu").open();
  else controlP5.getGroup("menu").close();
}

/// creates an image from your screen
void screenshot() {
  try {
    Robot robot = new Robot();
    screenshot = new PImage(robot.createScreenCapture(new Rectangle(0, 0, width, height)));
  } 
  catch (AWTException e) {
  }
}

/// source image, blank image for black and white dither, 
/// factor is a float that changes the amount of black of the image, and the structure of the dither
void dither(PImage src1, float factor, int lev) {
  int s = 1;
  //println(factor);
  ///create a copy of the original image///
  PImage src = createImage(src1.width, src1.height, RGB);
  for (int i = 0; i < src.pixels.length; i++) {
    src.pixels[i] = src1.pixels[i];
  }
  src.loadPixels();
  for (int x = 2; x < src.width-2; x+=s) {
    for (int y = 2; y < src.height-2; y+=s) {
      int index = x + y * src.width;
      color oldpixel = src.pixels[index];
      color newpixel = findClosestColor(oldpixel, lev); //con 8 pixel sorting
      src.pixels[index] = newpixel;
      color quant_error = subColor(oldpixel, newpixel);

      //Floyd Steinberg
      color s1 = src.pixels[(x + s)+ ( y * src.width)];
      src.pixels[(x + s)+ ( y * src.width)] = quantizedColor(s1, quant_error, (7.0 + num)/factor);
      color s2 = src.pixels[(x - s)+ ( (y + s)     * src.width)];
      src.pixels[(x - s)+ ( (y + s) * src.width)] = quantizedColor(s2, quant_error, (3.0 + num)/factor);
      color s3 = src.pixels[x + ( (y + s) * src.width)];
      src.pixels[x + ( (y + s) * src.width)] = quantizedColor(s3, quant_error, (5.0 + num)/factor);
      color s4 = src.pixels[(x + s)+ ((y + s ) * src.width)];
      src.pixels[(x + s)+ ((y + s ) * src.width)] = quantizedColor(s4, quant_error, (1.0 + num)/factor);
    }
  }
  //src2.loadPixels(); // add src2 on top
  //for (int index = 0; index < src.pixels.length; index++) {
  //  float b = brightness(src.pixels[index]);
  //  int bwPix = b < 125 ? 0 : 255;
  //  src2.pixels[index] = color(bwPix);
  //}
  //src2.updatePixels();
  src.updatePixels();
  //image(src1, 0, 0);
  image(src, 0, 0);
}

/// find the nearest color, lev defines the number ///
/// of colors the image will be divided,           /// 
/// with 1 meaning 8 colors (RGB + CMYK + WHITE)   ///

color findClosestColor(color in, int lev) {

  float r = (in >> 16) & 0xFF;
  float g = (in >> 8) & 0xFF;
  float b = in & 0xFF;
  ///Normalizing the colors///
  //level = lev;
  float norm = 255.0 / lev;
  float nR = round((r / 255) * lev) * norm;
  float nG = round((g / 255) * lev) * norm;
  float nB = round((b / 255) * lev) * norm;
  color newPix = color (nR, nG, nB);
  return newPix;
}


/////subtracting two different colors (a - b)////
color subColor (color a, color b) {

  float r1 = (a >> 16) & 0xFF;
  float g1 = (a >> 8) & 0xFF;
  float b1 = a & 0xFF;

  float r2 = (b >> 16) & 0xFF;
  float g2 = (b >> 8) & 0xFF;
  float b2 = b & 0xFF;

  float r3 = r1 - r2;
  float g3 = g1 - g2;
  float b3 = b1 - b2;

  color c = color(r3, g3, b3);
  return c;
}

/////returns the result between the original color and the quantization error////
color quantizedColor(color c1, color c2, float mult ) {

  float r1 = (c1 >> 16) & 0xFF;
  float g1 = (c1>> 8) & 0xFF;
  float b1 = c1 & 0xFF;

  float r2 = (c2 >> 16) & 0xFF;
  float g2 = (c2>> 8) & 0xFF;
  float b2 = c2 & 0xFF;

  float nR = r1 + mult * r2;
  float nG = g1 + mult * g2;
  float nB = b1 + mult * b2;

  color c3 = color (nR, nG, nB);
  return c3;
}