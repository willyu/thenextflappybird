import java.util.ArrayList;
import java.util.Collections;

int index = 0;

boolean mousePressed = true;
//your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;

// designates the blue grab circle size
int grabSize = 30;

int trialCount = 20; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0;
int errorCount = 0;  
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;

final int screenPPI = 120; //what is the DPI of the screen you are using
//Many phones listed here: https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays 

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
  size(400, 700); //set this, based on your sceen's PPI to be a 2x3.5" area.

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
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
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

  fill(255, 0, 0); //set color to red
  rect(0, 0, t.z, t.z);

  popMatrix();
  
  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();
  
  translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen
  rotate(radians(screenRotation));
  
  fill(0, 255, 255, 128);
  
  //draw grab circle
  ellipse(0, 0, sqrt(2)*screenZ + grabSize, sqrt(2)*screenZ + grabSize);
  fill(60, 128);
  ellipse(0, 0, sqrt(2)*screenZ, sqrt(2)*screenZ);
 
  //draw square
  fill(255, 128);
  rect(0, 0, screenZ, screenZ);
  
  popMatrix();
  
  //===========DRAW TRAFFIC LIGHT=========================
  fill(0, 255, 0);
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"  

  if (closeRotation){
    ellipse(30,30,30,30);
  }
  if (closeZ){
    ellipse(60,30,30,30);
  }
  
  
  scaffoldControlLogic(); //you are going to want to replace this!
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

void scaffoldControlLogic()
{
  // auto progress
  if (checkForSuccess())
  {
    next();
    return;
  }
  
  if (moveBox())
  {
    screenTransX = mouseX;
    screenTransY = mouseY-200;
    screenRotation++;
  }
  
  if (resizeBox())
  {
    screenZ = sqrt(2)*(dist(mouseX,mouseY,screenTransX,screenTransY) - grabSize/2);
    
  }
}

void mousePressed()
{
  mousePressed = true;
}


void mouseReleased()
{
  mousePressed = false;
}

public boolean checkForSuccess()
{
  Target t = targets.get(trialIndex);
  System.out.print(dist(t.x,t.y,screenTransX, screenTransY) + "\n");//((screenTransX) + " " +  (screenTransY) + " " + t.x + " " + t.y + "\n");

  boolean closeDist = dist(t.x,t.y,screenTransX,screenTransY)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"
  
  println("Close Enough Distance: " + closeDist);
  println("Close Enough Rotation: " + closeRotation + " ("+(t.rotation+360)%90+","+ (screenRotation+360)%90+")");
  println("Close Enough Z: " + closeZ);
  return closeDist && closeRotation && closeZ;
}

double calculateDifferenceBetweenAngles(float a1, float a2)
{
  a1+=360;
  a2+=360;
  if (abs(a1-a2)>45)
    return abs(abs(a1-a2)%90-90);
  else
    return abs(a1-a2)%90;
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
} 