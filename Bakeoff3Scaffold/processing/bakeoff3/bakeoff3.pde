import java.util.ArrayList;
import java.util.Collections;

int index = 0;

int double_tap_threshold=1000;
int press_and_hold_time_threshold=200;
int press_and_hold_movement_threshold=4;



boolean mousePressed = true;
//your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;
int i=0;
int n=0;
int m=0;
int resizeX=0;
int resizeY=0;
int md_x=0;
int md_y=0;
float resizeZ=0;
double distR=0;
double distZ=0;
double distXY=0;
int action=0;
// designates the blue grab circle size
int grabSize = 30;

int trialCount = 4; //this will be set higher for the bakeoff
float border = 300; //have some padding from the sides
int trialIndex = 0;
int errorCount = 0;  
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
boolean rotating = true;
final int screenPPI = 445; //what is the DPI of the screen you are using
//Many phones listed here: https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays 

int lastPressed = 0;

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  //size does not let you use variables, so you have to manually compute this
  size(890, 1558); //set this, based on your sceen's PPI to be a 2x3.5" area.

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.15f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    t.z = ((i%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0"
    targets.add(t);
    //println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void draw() {

  background(60); //background is dark grey
  fill(200);
  noStroke();

  if (startTime == 0)
    startTime = millis();

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);

    return;
  }
  

  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen

  Target t = targets.get(trialIndex);
  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  
  rotate(radians(t.rotation));

  fill(0);
  ellipse(0, 0, sqrt(2)*t.z + grabSize, sqrt(2)*t.z + grabSize);
  fill(255, 0, 0); //set color to red
  
  rect(0, 0, t.z, t.z);
  
  fill(0);
  rect(0,0,2,2);

  popMatrix();
  
  
  
  distR= abs((t.rotation%90)-(screenRotation%90));
  distXY=dist(t.x,t.y,screenTransX,screenTransY);
  distZ=abs(t.z - screenZ);
  //println(t.x+"  "+t.y+"  "+screenTransX+"  "+screenTransY+"   "+distR+"   "+dist(t.x,t.y,screenTransX,screenTransY)+" "+calculateDifferenceBetweenAngles(t.rotation,screenRotation));
  boolean closeRotation = distR<=5;
  boolean closeXY=distXY<inchesToPixels(.05f);
  boolean closeZ = distZ<inchesToPixels(.05f); //has to be within .1"  
  

  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();
  translate(width/2, height/2);
  translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen
  
  rotate(radians(screenRotation));
  
  fill(0, 255, 255, 128);
  
  if (closeRotation){
    fill(0, 200-(float)distXY, 0);
  }
  //draw grab circle
  ellipse(0, 0, sqrt(2)*screenZ + grabSize, sqrt(2)*screenZ + grabSize);
  fill(60, 128); 
  if (closeZ){
    fill(0,200, 0);
  }

  ellipse(0, 0, sqrt(2)*screenZ, sqrt(2)*screenZ);


  fill(255, 128);
  if (closeXY){
    fill(0, 150-(float)distXY, 0);
  }
  //draw square

  
  rect(0, 0, screenZ, screenZ);
  
  popMatrix();
  
  //===========DRAW TRAFFIC LIGHT=========================
  

  fill(255-(float)distR, 255-(float)distR, 255-(float)distR);
  if (closeRotation){
    fill(0, 255, 0);
  }
  
  ellipse(60,30,30,30);
  fill(255-(float)distZ, 255-(float)distZ, 255-(float)distZ);
  if (closeZ){
    fill(0,255- (float)distZ, 0);
  }
  ellipse(30,30,30,30);
  
  fill(255-(float)distXY, 255-(float)distXY, 255-(float)distXY);
  if (closeXY){
    fill(0, 255-(float)distXY, 0);
  }
  ellipse(90,30,30,30);
  
  scaffoldControlLogic(); //you are going to want to replace this!
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

void scaffoldControlLogic()
{
  fill(255);
  text("-", inchesToPixels(.2f), height-inchesToPixels(.2f));
  if (mousePressed && dist(inchesToPixels(.2f), height, mouseX, mouseY)<inchesToPixels(.5f) && !userDone) {
    screenRotation-=1;
  }
  
  text("+", width/2, height-inchesToPixels(.2f));
  if (mousePressed && dist(width/2, height-inchesToPixels(.2f), mouseX, mouseY)<inchesToPixels(.5f) && !userDone) {
    screenRotation+=1;
  }
  
  //lower right corner
  text("next", width-inchesToPixels(.2f), height-inchesToPixels(.2f));
  if (mousePressed && dist(width, height, mouseX, mouseY)<inchesToPixels(.5f) && (millis() - lastPressed > 2000) && !userDone) {
    lastPressed = millis();
    next();
  }
  
  
  
  //println("i: "+i + " m "+ (millis()-m)+ " d: "+dist(md_x,md_y,mouseX,mouseY) + " rot " + screenRotation);
  if(i==1 && millis()-m>press_and_hold_time_threshold){
    
    if(dist(md_x,md_y,mouseX,mouseY) < press_and_hold_movement_threshold){
      action=1;
    }else{
      action=2;
    }
    action=2;
    i=0;
      
  }
  if(!mousePressed){
    action=0;
  }
  if(action==1|| rotating){
    screenRotation+=2;
    screenRotation=screenRotation%360;
  }
  if (action==0)
  {
    screenTransX = mouseX-width/2;
    screenTransY = mouseY-height/2;

  }
  
  if(action==2)
  {
    screenZ = dist(md_x,md_y,mouseX,mouseY );
    
  }
}

void mousePressed()
{
  if (!((dist(width/2, height-inchesToPixels(.2f), mouseX, mouseY)<inchesToPixels(.5f)) || dist(inchesToPixels(.2f), height, mouseX, mouseY)<inchesToPixels(.5f))) {
    if(i==0){
      m = millis(); 
    }
    i++;
    if(i==2){
       n=millis();
    }
  }
  md_x=mouseX;
  md_y=mouseY;
  mousePressed = true;
}


void mouseReleased()
{
  if(i==2){
    if(n-m < double_tap_threshold){
      action=1;
      resizeX=mouseX;
      resizeY=mouseY;
      resizeZ=screenZ;
      rotating=!rotating;
    }
    i=0;
    n=0;
    m=0;

  }
  action=0;
  mousePressed = false;
}



  public boolean checkForSuccess()
  {
    Target t = targets.get(trialIndex);  
    boolean closeDist = dist(t.x,t.y,screenTransX,screenTransY)<inchesToPixels(.05f); //has to be within .1"
    distR= abs((t.rotation%90)-(screenRotation%90));
    boolean closeRotation = distR<=5;
    boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"
    System.out.println("closeDist: " + closeDist);
    System.out.println("closeRotation: " + closeRotation);
    System.out.println("closeZ: " + closeZ);
    
    return closeDist && closeRotation && closeZ;
  }

  double calculateDifferenceBetweenAngles(float a1, float a2)
    {
      return abs((a1%90)-(a2%90));
        //a1+=360;
        //a2+=360; 
      
        //if (abs(a1-a2)>45)
          //return abs(abs(a1-a2)%90-90);
        //else
          //return abs(a1-a2)%90;
   }


boolean moveBox(){
  //mouse pressed outside of resize ring
  return (mousePressed && ((dist(mouseX,mouseY, screenTransX, screenTransY) < sqrt(2)*screenZ/2) || ( dist(mouseX,mouseY, screenTransX, screenTransY) > sqrt(2)*screenZ/2 + grabSize)));
}

boolean resizeBox(){
  //mouse pressed inside resize ring
  return (mousePressed && ((dist(mouseX,mouseY, screenTransX, screenTransY) > sqrt(2)*screenZ/2) && (dist(mouseX,mouseY, screenTransX, screenTransY) < sqrt(2)*screenZ/2 + grabSize)));
}

void next()
{
 //called when boxes sucessfully overlapped
 if (userDone==false && !checkForSuccess())
   errorCount++;

 //and move on to next trial
 trialIndex++;

 screenTransX = 0;
 screenTransY = 0;

 if (trialIndex==trialCount && userDone==false)
 {
   userDone = true;
   finishTime = millis();
 }
 screenZ=20;
} 