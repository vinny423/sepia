import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.gamecontrolplus.gui.*; 
import org.gamecontrolplus.*; 
import java.util.List; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class sepia extends PApplet {





//General settings
boolean debug = false;
int fps = 60;
boolean joystickSet = false;
boolean joystickPreloaded = false;
boolean leftMouseClicked = false;
boolean mouseLocked = false;
boolean started = false;
boolean rpmLocked, pitchLocked, rollLocked, speedLocked;

//Instruments positions
int positionX = 370;
int spacingX = 450;
int positionY = 500;
int spacingY = 400;
int titleTextSize = 17;
float titleTextOffset = 20;

Horizon horizon;
Tachometer tacho;
Compass compass;
Altimeter altimeter;
Airspeed airspeed;
Vario vario;

//Rotactors
String[] textOdd= {"N", "3", "5", "7", "9"};
String[] textPair = {"N", "2", "4", "6", "8"};
Rotactor rotacteurPair;
Rotactor rotacteurOdd;

Button joystickButton;
Exercice exercice;

public void settings() {
  size(1920, 1080);
}

public void setup() {
  frameRate(fps);
  control = ControlIO.getInstance(this);
  
  if(!joystickSet) setupJoystick();
  
  //Instruments
  altimeter = new Altimeter(width*3/4, height/2);

  horizon = new Horizon(width/4, height/2);

  compass = new Compass(width/2, height/2);

  tacho = new Tachometer(width*1/8, height*4/5);

  airspeed = new Airspeed(width*3/8, height*4/5);

  vario = new Vario(width*5/8, height*4/5);

  rotacteurOdd = new Rotactor(width/12, height*3/8, textOdd);
  rotacteurPair = new Rotactor(width/12, height*5/9, textPair);
  
  joystickButton = new Button("j",width-75,height-75,75,75);
  joystickButton.setColor(color(0xff083471));
  joystickButton.setTextColor(color(255));
  
  resetFlight();
  
  exercice = new Exercice(altitude,bearing);
  
  rpmLocked = false;
  rollLocked = pitchLocked = speedLocked = true;
}

public void draw() {
  background(200);
  
  if(joystickSet){
    
    getUserInput();
    flight();
  
    fill(50);
    stroke(0);
    strokeWeight(10);
    rectMode(CORNER);
    rect(0, height, width, -height*0.75f, 180, 180, 0, 0);
  
    validateValues();
  
    displayInstruments();
    
    joystickButton.display();
    
    exercice.run();
    
    if(joystickButton.clicked){
      joystickSet = false;
    }
  }else{
    displayJoystickConfig();
    if(started) reset();
  }
}

public void displayInstruments(){
  tacho.display(rpm/100);
  
  altimeter.display(altitude);

  compass.display(bearing);

  horizon.display(pitch, bank);

  airspeed.display(speed);

  vario.display(fpm);

  rotacteurOdd.display(rotacteurOddSelection);
  rotacteurPair.display(rotacteurPairSelection);
}

public void reset(){
  rollLocked = pitchLocked = speedLocked = true;
  resetFlight();
  exercice = new Exercice(altitude,bearing);
  println("Exercice reset");
}

public void keyPressed() {
  //Rotactors
  if (key == 'z') rotacteurOddSelection++;
  else if (key == 'a') rotacteurOddSelection--;
    
  if (key == 's') rotacteurPairSelection++;
  else if (key == 'q') rotacteurPairSelection--;
  
  if(key == 'r') reset();
  
  if(key == ENTER){
    exercice.start();
    rpmLocked = pitchLocked = rollLocked = speedLocked = false;
  }
}

public void validateValues() {
  if (rotacteurOddSelection > textOdd.length-1) rotacteurOddSelection = textOdd.length-1;
  if (rotacteurOddSelection < 0) rotacteurOddSelection = 0;
  if (rotacteurPairSelection > textPair.length-1) rotacteurPairSelection = textPair.length-1;
  if (rotacteurPairSelection < 0) rotacteurPairSelection = 0;
}

/*void mouseClicked(){
  if(mouseButton == LEFT) leftMouseClicked = true;
}*/

public void mousePressed(){
  if(mouseButton == LEFT){
    leftMouseClicked = true;
  }
}

public void mouseReleased(){
  if(mouseButton == LEFT){
    leftMouseClicked = false;
    mouseLocked = false;
  }
}
class Airspeed{
  float x, y;
  
  int airspeedWidth = 350;
  float airspeedInsideScale = 0.95f;
  float airspeedInsideWidth = airspeedWidth*airspeedInsideScale;
  
  int smallLineLength = 23;
  int smallLineWidth = 2;
  
  int bigLineLength = 30;
  int bigLineWidth = 3;
  
  int textSize = 20;
  
  int maxSpeed = 160;
  int startSpeed = 40;
  int lineStep = 2;
  int textStep = 10;
  
  float airspeedAngleStart = radians(200);
  float airspeedAngleSpacing = radians(30);
  float airspeedAngleStep = (TWO_PI-airspeedAngleSpacing*2)/(maxSpeed-startSpeed);
  
  float needleScale = 0.80f;
  float needleLength = airspeedInsideWidth/2*needleScale;
  int needleWidth = 10;
  float needleTipLength = 20;
  float needleCornerAngle = 360;
  int needleCacheWidth = 20;
  int needleOffset = 5;
  
  Airspeed(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public void displayFixed(){
    noStroke();
    
    strokeCap(SQUARE);
    textSize(textSize);
    textAlign(CENTER,CENTER);
    
    //Outter circle
    fill(0);
    ellipse (x,y,airspeedWidth,airspeedWidth);
    
    //Inner circle
    strokeWeight(2);
    stroke(255);
    fill(20);
    ellipse (x,y,airspeedInsideWidth,airspeedInsideWidth);
    
    
    for(int i=startSpeed; i<=maxSpeed; i+=lineStep){
      pushMatrix();
      translate(x,y);
      rotate((i-startSpeed)*airspeedAngleStep+airspeedAngleStart);
      
      stroke(255);
      
      if(i%textStep == 0){
        strokeWeight(bigLineWidth);
        line(0,0-airspeedInsideWidth/2+bigLineLength,0,0-airspeedInsideWidth/2);
        
        popMatrix();
        
        fill(255);
        float angle = (i-startSpeed)*airspeedAngleStep+airspeedAngleStart+PI/2;
        text(i,x-(airspeedInsideWidth/2-bigLineLength-textSize)*cos(angle),y-(airspeedInsideWidth/2-bigLineLength-textSize)*sin(angle));
        
        pushMatrix();
        translate(x,y);
        rotate(i*airspeedAngleStep+airspeedAngleStart);
      } else {
        strokeWeight(smallLineWidth);
        line(0,0-airspeedInsideWidth/2+smallLineLength,0,0-airspeedInsideWidth/2);
      }
      popMatrix();
    }
    
    textSize(titleTextSize);
    text("AIRSPEED",x,y-titleTextOffset);
    text("KNOTS",x,y+titleTextOffset);
  }
  
  public void display(float speed){
    displayFixed();
    
    noStroke();
    pushMatrix();
    translate(x,y);
    rotate((speed-startSpeed)*airspeedAngleStep+airspeedAngleStart);
    
    //Needle
    rect(-needleWidth/2,needleOffset,needleWidth,-needleLength,0,0,needleCornerAngle,needleCornerAngle);
    triangle(-needleWidth/2,-needleLength*0.995f+needleOffset,needleWidth/2,-needleLength*0.995f+needleOffset,0,-needleLength-needleTipLength);
    
    popMatrix();
    
    noStroke();
    ellipse(x,y,needleCacheWidth,needleCacheWidth);
  }
}
class Altimeter{
  float x, y;
  
  int altimeterWidth = 350;
  float altimeterInsideScale = 0.95f;
  float altimeterInsideWidth = altimeterWidth*altimeterInsideScale;
  
  float smallLineLength = 12;
  float smallLineWidth = 2;
  
  float bigLineLength = 25;
  float bigLineWidth = 4;
  
  float altimeterTextOffset = 25;
  float altimeterTextSize = 40;
  float altimeterCounterTextSize = 30;
  
  float altimeterAngleStep = radians(7.2f);
  
  float thousandsNeedleScale = 0.6f;
  float thousandsNeedleLength = altimeterInsideWidth/2*thousandsNeedleScale;
  float thousandsNeedleWidth = 15;
  
  float hundredsNeedleScale = 0.85f;
  float hundredsNeedleLength = altimeterInsideWidth/2*hundredsNeedleScale;
  float hundredsNeedleWidth = 10;
  
  float needleTipLength = 20;
  float needleCornerAngle = 360;
  float needleCacheWidth = 20;
  float needleOffset = 0.55f;
  
  float quadrantOffset = altimeterWidth/7.143f;
  float quadrantWidth = altimeterWidth/2.5f;
  float quadrantHeight = altimeterWidth/9.1f;
  float quadrantLineWidth = 3;
  
  Altimeter(float x, float y){
    this.x = x;
    this.y = y;
    
    strokeCap(SQUARE);
    textAlign(CENTER,CENTER);
  }
  
  public void displayFixed(){
    textSize(altimeterTextSize);
    noStroke();
    fill(0);
    ellipse (x,y,altimeterWidth,altimeterWidth);
    
    strokeWeight(2);
    stroke(255);
    fill(20);
    ellipse (x,y,altimeterInsideWidth,altimeterInsideWidth);
    
    for(int i=0; i<50; i++){
      pushMatrix();
      translate(x,y);
      rotate(i*altimeterAngleStep);
      
      stroke(255);
      
      if(i%5 == 0){
        strokeWeight(bigLineWidth);
        line(0,0-altimeterInsideWidth/2+bigLineLength,0,0-altimeterInsideWidth/2);
        
        popMatrix();
        
        fill(255);
        text(i*1/5,x-(altimeterInsideWidth/2-bigLineLength-altimeterTextOffset)*cos(i*altimeterAngleStep+HALF_PI),y-(altimeterInsideWidth/2-bigLineLength-altimeterTextOffset)*sin(i*altimeterAngleStep+HALF_PI));
        
        pushMatrix();
        translate(x,y);
        rotate(i*altimeterAngleStep);
      } else {
        strokeWeight(smallLineWidth);
        line(0,0-altimeterInsideWidth/2+smallLineLength,0,0-altimeterInsideWidth/2);
      }
      popMatrix();
    }
    
    textSize(titleTextSize);
    text("ALTIMETER",x,y-titleTextOffset);
  }
  
  public void display(float altitude){
    displayFixed();
    
    textSize(altimeterCounterTextSize);
    stroke(255);
    strokeWeight(quadrantLineWidth);
    fill(0);
    rectMode(CENTER);
    
    rect(x,y+quadrantOffset,quadrantWidth,quadrantHeight);
    for(int j=1; j<=5; j++){
      float lineX = x-quadrantWidth/2+j*quadrantWidth/5;
      float lineY1 = y+quadrantOffset/2+quadrantLineWidth*2;
      float lineY2 = y+quadrantOffset/2+quadrantHeight+quadrantLineWidth*2;
      
      line(lineX,lineY1,lineX,lineY2);
      fill(255);
      char[] altitudeArray = nf(PApplet.parseInt(altitude),5).toCharArray();
      altitudeArray[4] = '0';
      text(altitudeArray[j-1],lineX-quadrantWidth/10,lineY1+quadrantHeight/2-quadrantLineWidth*2);
    }
    
    noStroke();
    pushMatrix();
    translate(x,y);
    
    //Thousands
    float thousands = altitude/1000;
    
    pushMatrix();
    rotate(thousands*5*altimeterAngleStep);
    rectMode(CORNER);
    
    fill(245);
    
    rect(-thousandsNeedleWidth/2,0,thousandsNeedleWidth,-thousandsNeedleLength);
    triangle(-thousandsNeedleWidth/2,-thousandsNeedleLength+needleOffset,thousandsNeedleWidth/2,-thousandsNeedleLength+needleOffset,0,-thousandsNeedleLength-needleTipLength);
    
    popMatrix();
    
    //Hundreds
    float hundreds = altitude-(floor(altitude)/1000)*1000;
    
    pushMatrix();
    rotate(hundreds/100*5*altimeterAngleStep);
    
    rect(-hundredsNeedleWidth/2,0,hundredsNeedleWidth,-hundredsNeedleLength);
    triangle(-hundredsNeedleWidth/2,-hundredsNeedleLength+needleOffset,hundredsNeedleWidth/2,-hundredsNeedleLength+needleOffset,0,-hundredsNeedleLength-needleTipLength);
    
    popMatrix();
    popMatrix();
    
        
    noStroke();
    ellipse(x,y,needleCacheWidth,needleCacheWidth);
  }
}
class Button{
  
  boolean clicked;
  
  float x,y;
  
  String text;
  
  int textSize = 25;
  
  float buttonWidth;
  float buttonHeight;
  
  float buttonBorder = 1;
  
  int defaultBackgroundColor, hoverBackgroundColor, clickedBackgroundColor;
  int textColor = color(0);
  
  Button(String text, float x, float y, float buttonWidth, float buttonHeight){
    this.text = text;
    this.x = x;
    this.y = y;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    
    setColor(color(255));
  }
  
  Button(String text, float x, float y){
    this(text,x,y,530,100);
  }
  
  public void setColor(int newColor){
    defaultBackgroundColor = newColor;
    hoverBackgroundColor = color(red(defaultBackgroundColor),green(defaultBackgroundColor)-10,blue(defaultBackgroundColor)-30);
    clickedBackgroundColor = color(red(defaultBackgroundColor),green(defaultBackgroundColor)-10,blue(hoverBackgroundColor)-30);
  }
  
  public void setTextColor(int textColor){
    this.textColor = textColor;
  }
  
  public void setPosition(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public void display(float x, float y){
    checkMouse();
    rectMode(CENTER);
    stroke(0);
    strokeWeight(buttonBorder);
    textAlign(CENTER,CENTER);
    textSize(textSize);
    rect(x,y,buttonWidth/2,buttonHeight/2);
    fill(textColor);
    text(text,x,y);
  }
  
  public void display(){
    display(x,y);
  }
  
  public void setText(String text){
    this.text = text;
  }
  
  public void setTextSize(int textSize){
    this.textSize = textSize;
  }
  
  public void setSize(float buttonWidth, float buttonHeight){
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
  }
  
  public void checkMouse(){
    if(overRect(x,y,buttonWidth/4,buttonHeight/4)){
       fill(hoverBackgroundColor);
       if(leftMouseClicked){
         fill(clickedBackgroundColor);
         if(!mouseLocked){
           clicked = true;
           mouseLocked = true;
         } else clicked = false;
       } else clicked = false;
    } else {
      fill(defaultBackgroundColor);
      clicked = false;
    }
  }
  
  public boolean overRect(float x, float y, float lWidth, float lHeight) {
    if (mouseX >= x-lWidth && mouseX <= x+lWidth && mouseY >= y-lHeight && mouseY <= y+lHeight) return true;
    else return false;
  }
}
class Calculus{
  
  int num1Min = 100;
  int num1Max = 900;
  int num2Min = 10;
  int num2Max = 100;
  
  int multMin = 50;
  int multMax = 200;
  int multLow[] = {2,3,4};
  
  int divLow[] = {2,3};
  
  int divMin = 50;
  int divMax = 300;
  int result;
  
  Calculus(){
    
  }
  
  public String getRandomCalculation(){
    String calculation;
    
    int rand = PApplet.parseInt(random(100));
    
    
    if(rand<35) calculation = getAddition();
    else if(rand<70) calculation = getSubstraction();
    else if(rand<90) calculation = getMultiplication();
    else calculation = getDivision();
    
    return calculation;
  }
  
  public String getAddition(){
    int num1 = PApplet.parseInt(random(num1Min,num1Max));
    int num2 = PApplet.parseInt(random(num2Min,num2Max));
    
    result = num1 + num2;
    
    return num1 +" + "+num2;
  }
  
  public String getSubstraction(){
    int num1 = PApplet.parseInt(random(num1Min,num1Max));
    int num2 = PApplet.parseInt(random(num2Min,num2Max));
    
    result = num1 - num2;
    
    return num1 +" - "+num2;
  }
  
  public String getMultiplication(){
    int mult1 = PApplet.parseInt(random(multMin,multMax));
    int mult2 = multLow[PApplet.parseInt(random(multLow.length))];
    
    result = mult1 * mult2;
    
    return mult1 +" x "+mult2;
  }
  
  public String getDivision(){
    int div2 = divLow[PApplet.parseInt(random(divLow.length))];
    int div1 = PApplet.parseInt(random(divMin,divMax))*div2;
    
    result = div1/2;
    
    return div1 +" ÷ "+div2;
  }
  
  public int getResult(){
    return result;
  }
}
class Checkbox{
  float x,y;
  float size;
  float lineSize = 2;
  
  int defaultBackgroundColor = color(255);
  int hoverBackgroundColor = color(230);
  
  boolean clicked = false;
  boolean active = false;
  
  Checkbox(float x, float y, float size){
    this.x = x;
    this.y = y;
    this.size = size;
  }
  
  Checkbox(float x, float y){
    this(x,y,40);
  }
  
  Checkbox(){
    this(0,0,40);
  }
  
  public void display(){
    fill(defaultBackgroundColor);
    if(!mouseLocked)checkMouse();
    rectMode(CENTER);
    strokeWeight(1);
    stroke(0);
    rect(x,y,size/2,size/2);
    if(active){
      strokeWeight(lineSize);
      line(x-size/4,y-size/4,x+size/4,y+size/4);
      line(x+size/4,y-size/4,x-size/4,y+size/4);
    }
  }
  
  public void setPosition(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public void setActive(boolean active){
    this.active = active;
  }
  
  public void checkMouse(){
    if(overRect(x,y,size/4,size/4)){
       fill(hoverBackgroundColor);
       if(leftMouseClicked){
         if(!mouseLocked){
           if(active) active = false;
           else active = true;
           mouseLocked = true;
         }
       }
    } else {
      fill(defaultBackgroundColor);
    }
  }
  
  public boolean overRect(float x, float y, float lWidth, float lHeight) {
    if (mouseX >= x-lWidth && mouseX <= x+lWidth && mouseY >= y-lHeight && mouseY <= y+lHeight) return true;
    else return false;
  }
}
class Compass{
  float x, y;
  
  float compassWidth = 350;
  float compassInsideScale = 0.95f;
  float compassInsideWidth = compassWidth*compassInsideScale;
  
  float smallLineLength = 12;
  float smallLineWidth = 2;
  
  float bigLineLength = 22;
  float bigLineWidth = 3;
  
  float compassTextOffset = 20;
  float compassTextSize = compassWidth/12.5f;
  
  float bearingIndicatorWidth = 3;
  float bearingIndicatorLength = 50;
  float compassIndicatorOffset = 10;
  
  Compass(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public void displayFixed(){
    fill(0);
    ellipse (x,y,compassWidth,compassWidth);
  }
  
  public void display(float rotation){
    displayFixed();
    
    noStroke();
    pushMatrix();
    translate(x,y);
    rotate(radians(rotation%360));
    strokeWeight(2);
    stroke(255);
    fill(25);
    ellipse (0,0,compassInsideWidth,compassInsideWidth);
    
    stroke(255);
    textAlign(CENTER,CENTER);
    textSize(compassTextSize);
    
    for(int i=0; i<36*2; i++){
      pushMatrix();
      rotate(radians(i*5));
      if(i%2 == 1){
        strokeCap(SQUARE);
        strokeWeight(smallLineWidth);
        line(0,0-compassInsideWidth/2+smallLineLength,0,0-compassInsideWidth/2);
      } else {
        strokeWeight(bigLineWidth);
        line(0,0-compassInsideWidth/2+bigLineLength,0,0-compassInsideWidth/2);
        if(i%9 == 0){
          String letter;
          
          switch(i/2){
            case 0: letter = "N"; break;
            case 9: letter = "E"; break;
            case 18: letter = "S"; break;
            case 27: letter = "W"; break;
            default: letter = ""; break;
          }
          fill(255);
          text(letter,0,0-compassInsideWidth/2+bigLineLength+compassTextOffset);
        } else if(i%6 == 0){
          fill(255);
          text(i/2,0,0-compassInsideWidth/2+bigLineLength+compassTextOffset);
        }
      }

      popMatrix();
    }
    
    popMatrix();
    noStroke();
    stroke(0xffF07F00);
    strokeWeight(bearingIndicatorWidth);
    line(x,y-compassInsideWidth/2+bearingIndicatorLength,x,y-compassInsideWidth/2+compassIndicatorOffset);
    noStroke();
  }
}
class DropdownList{
  String[] elements;
  String firstElement;
  Button[] buttons;
  
  float x,y;
  
  float listWidth;
  float listHeight;
  
  boolean folded = true;
  boolean disabled = false;
  
  DropdownList(float x, float y, float listWidth, float listHeight, String firstElement, String[] elements){
    elements = splice(elements,firstElement,0);
    buttons = new Button[elements.length];
    for(int i=0; i<elements.length;i++) this.buttons[i] = new Button(elements[i],x,y+listHeight/2*i,listWidth,listHeight);
    this.x = x;
    this.y = y;
    this.listWidth = listWidth;
    this.listHeight = listHeight;
  }
  
  DropdownList(float x, float y, float listWidth, float listHeight, String firstElement){
    this.firstElement = firstElement;
    this.x = x;
    this.y = y;
    this.listWidth = listWidth;
    this.listHeight = listHeight;
  }
  
  public void setElements(String[] elements){
    elements = splice(elements,firstElement,0);
    this.elements = elements;
    buttons = new Button[elements.length];
    for(int i=0; i<elements.length;i++) this.buttons[i] = new Button(elements[i],x,y+listHeight/2*i,listWidth,listHeight);
  }
  
  public void setColor(int newColor){
    for(Button button : buttons) button.setColor(newColor);
  }
  
  public void setTextSize(int textSize){
    for(Button button : buttons) button.setTextSize(textSize);
  }
  
  public void setPosition(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public void display(){
    getClicks();
    if(folded) fold();
    else unfold();
  }
  
  public void setActive(String active){
    this.elements[0] = active;
  }
  
  public void getClicks(){
    for(Button button: buttons){
      if(button.clicked){
        if(button == buttons[0])
          if(folded) folded = false;
          else folded = true;
        else {
          buttons[0].setText(button.text);
          folded = true;
          button.clicked = false;
        }
      }
    }
  }
  
  public void unfold(){
    for(Button button : buttons){
      button.display();
    }
  }
  
  public void fold(){
    buttons[0].display();
  }
  
  public String getSelection(){
    return buttons[0].text;
  }
}
class Exercice{
  InstructionHandler ih;
  Calculus calc;
  
  float speedup = 1;
  
  float timeSinceLastAlt, timeSinceLastTurn, timeSinceLastCalc;
  float altInterval, turnInterval, calcInterval;
  
  float defaultAltInterval = 10000/speedup;
  float defaultTurnInterval = 20000/speedup;
  float defaultInterval = 5000/speedup;
  
  float defaultCalcInterval = 20000/speedup;
  float defaultResultInterval = 5000/speedup;
  float calcDelayMin = 25000/speedup;
  float calcDelayMax = 50000/speedup;
  boolean calcActive = false;
  boolean resultActive = false;
  
  float startAltitude = 3000;
  float startBearing = 0;
  
  float timeMargin = 0.65f;
  
  String currentInstruction, previousInstruction, currentCalculation;
  
  int calculationColor = color(255,0,0);
  
  int textColor = color(0);
  int textSize = 40;
  
  boolean levelFlight = true;
  
  Exercice(float startAltitude, float startBearing){
    ih = new InstructionHandler(startAltitude, startBearing);
    calc = new Calculus();
    
    this.startAltitude = startAltitude;
    this.startBearing = startBearing;
    currentInstruction = "APPUYER SUR ENTREE POUR COMMENCER";
    currentCalculation = "";
    started = false;
  }
  
  public void run(){
    if(started){
      
      //Calculus
      if(millis()-timeSinceLastCalc>calcInterval){
        if(!calcActive){
          currentCalculation = calc.getRandomCalculation();
          calcActive = true;
          calcInterval = defaultCalcInterval; 
        }else if(!resultActive){
          currentCalculation = currentCalculation+" = "+calc.getResult();
          calcInterval = defaultResultInterval;
          resultActive = true;
        }else{
          calcInterval = PApplet.parseInt(random(calcDelayMin,calcDelayMax));
          calcActive = false;
          resultActive = false;
          currentCalculation = "";
        }
        timeSinceLastCalc = millis();
      }
      
      //Altitude change
      if(millis()-timeSinceLastAlt>altInterval){
        if(!levelFlight){
          currentInstruction = ih.getRandomAltitudeInstruction();
          altInterval = ih.getAltitudeDelta()/ih.getAltTime()*60000;
          levelFlight = true;
        } else{
          currentInstruction = ih.setLevel();
          altInterval = 0;
          levelFlight = false;
        }
        timeSinceLastAlt = millis();
        altInterval += altInterval*timeMargin;
        if(altInterval==0) altInterval = defaultAltInterval;
        previousInstruction = currentInstruction;
        altInterval/=speedup;
        println("Alt changed at "+millis()+" ms");
        println(altInterval/1000+" seconds until next altitude change");
        if(turnInterval - millis() - timeSinceLastTurn < defaultInterval){
          turnInterval += defaultInterval;
          println("New bearing in: "+turnInterval/1000);
        }
        println("");
      }
      
      //Bearing change
      if(millis()-timeSinceLastTurn>turnInterval){
        currentInstruction = ih.getRandomTurnInstruction();
        timeSinceLastTurn = millis();
        turnInterval = ih.getTurnRadius()/ih.getTurnTime()*1000;
        turnInterval += turnInterval*timeMargin;
        if(turnInterval==0) turnInterval = defaultTurnInterval;
        previousInstruction = currentInstruction;
        turnInterval/=speedup;
        println("Bearing changed at "+millis()+" ms");
        println(turnInterval/1000+" seconds until next bearing change");
        if(altInterval - millis() - timeSinceLastAlt < defaultInterval){
          altInterval += defaultInterval;
          println("New alt in: "+altInterval/1000);
        }
        println("");
      }
    }
    displayCurrentInstruction();
    displayCurrentCalculation();
  }
  
  public void displayCurrentInstruction(){
    fill(textColor);
    textSize(textSize);
    textAlign(CENTER,CENTER);
    text(currentInstruction,width/2,height*0.1f);
  }
  
  public void displayCurrentCalculation(){
    fill(calculationColor);
    textSize(textSize);
    textAlign(CENTER,CENTER);
    text(currentCalculation,width/2,height*0.18f);
  }
  
  public void start(){
    altInterval = 0;
    turnInterval = PApplet.parseInt(random(25000,30000))/speedup;
    calcInterval = PApplet.parseInt(random(calcDelayMin,calcDelayMax));
    started = true;
  }
}
//Flight settings
float bankDeadzone = 0.9f;
float pitchDeadzone = 0.05f;

////Environment parameters
float airDensity = 1.225f; //kg/m^3

////Aircraft parameters
//Performance
float maxRollRate = 0.2f; //°/s
float maxPitchRate = 0.1f; //°/s
float maxSpeed = 190; //kts
float minSpeed = 0; //kts

float naturalPitch = 0.002f;
float naturalBank = 0.001f;

//Engine
float maxRpm = 2700;
float idleRpm = 600;
float propDiameter = 70.8661f;//75; //Inches
int propPitch = 63; //Inches
int maxPower = 182;
float idlePower = maxPower*0.15f;
float power;
float propellerEfficiency = 0.85f;

//Wings
float wingArea = 10.85f; //m² 16.17
float wingSpan = 8.06f; //m 11
float wingAspectRatio = sq(wingSpan)/(wingArea);
float oswaldEfficiencyFactor = 0.7f;
float a = radians(TWO_PI);
float b = 0;
float c = 1/(PI*wingAspectRatio*oswaldEfficiencyFactor);
float d = 0.039f;

//Forces
float mass = 750; //Kg 900
float g = 9.80665f; //m/s²
float weight = mass * g; //N

////Starting parameters
float pitch; //°
float bank; //°
float bearing; //°
float startBearing = 0;
float altitude; //ft
float startAltitude = 3000;
float rpm ; //rpm
int rotacteurOddSelection;
int rotacteurPairSelection;
float speed; //kts
float tas;
float fpm; //ft/mn

////Live flight data
float liftCoefficient = a*pitch+b;
float lift = 0.5f*airDensity*sq(speed*0.5144f)*liftCoefficient*wingArea; //N

float dragCoefficient = c*sq(liftCoefficient)+d;
float drag = 0.5f*airDensity*sq(speed*0.5144f)*dragCoefficient*wingArea; //N

float incidence = (2*weight/(airDensity*sq(speed*0.5144f)*wingArea)-b)*1/liftCoefficient;
float aoa = pitch-incidence;

float thrust; //= 4.392399*pow(10,-8)*rpm*(pow(propDiameter,3.5)/sqrt(propPitch))*(4.23333*pow(10,-4)*rpm*propPitch-speed*0.5144); //N
float acceleration, accelerationX, accelerationY; //m/s


public void resetFlight(){
  pitch = 0; //°
  bank = 0; //°
  bearing = startBearing; //°
  altitude = startAltitude; //ft
  rpm = 1200; //rpm
  rotacteurOddSelection = 0;
  rotacteurPairSelection = 0;
  speed = 99; //kts
  fpm = 0; //ft/mn
}

public void flight() {
  if(!rpmLocked){
    rpm = map(throttle, -1, 1, idleRpm, maxRpm);
    power = map(throttle, -1, 1, idlePower, maxPower);
  }
  
  if(!rollLocked){
    bank += map(x, -1, 1, maxRollRate, -maxRollRate);
    if(bank<-bankDeadzone) bank -= bank*naturalBank;
    else if(bank>bankDeadzone) bank -= bank*naturalBank;
  }
  
  if(!pitchLocked){
    pitch += map(y, -1, 1, -maxPitchRate, maxPitchRate);
    if(pitch<-pitchDeadzone) pitch -= pitch*naturalPitch;
    else if(pitch>pitchDeadzone) pitch -= pitch*naturalPitch;
  }
  
  incidence = degrees((2*weight/(airDensity*sq(speed*0.5144f)*wingArea)-b)*1/5.5f);
  aoa = pitch-incidence;
  
  tas = speed+altitude/200;
  
  liftCoefficient = a*(pitch)+b;
  lift = 0.5f*airDensity*sq(tas*0.5144f)*liftCoefficient*wingArea; //N

  dragCoefficient = c*sq(liftCoefficient)+d;
  drag = 0.5f*airDensity*sq(tas*0.5144f)*dragCoefficient*wingArea; //N
  
  //thrust = 4.392399*pow(10,-8)*rpm*(pow(propDiameter,3.5)/sqrt(propPitch))*(4.23333*pow(10,-4)*rpm*propPitch-speed*0.5144); //N Dynamic thrust
  thrust = propellerEfficiency*power*745.6998f/(speed*0.5144f);
  
  acceleration = ((thrust-drag)*cos(radians(pitch))-lift*asin(radians(pitch)))/mass;//m/s
  
  /*float accelerationX = ((thrust-drag)*cos(radians(pitch))-lift*sin(radians(pitch)))/mass;
  float accelerationY = ((thrust-drag)*sin(radians(pitch))+lift*cos(radians(pitch))-weight)/mass;*/
  
  if(!speedLocked){
    accelerationX = ((thrust-drag)*cos(radians(pitch))+lift*sin(radians(pitch)))/mass;
    accelerationY = ((thrust-drag)*sin(radians(pitch))-lift*cos(radians(pitch))-weight)/mass;
    
    acceleration = (accelerationX*acos(radians(pitch)) + accelerationY*asin(radians(pitch)));
    
    speed += acceleration/(fps*0.5144f);
  }
  
  if(pitch<-pitchDeadzone || pitch>pitchDeadzone) fpm = sin(radians(pitch))*speed*101.269f;
  else fpm = 0;
  
  altitude += fpm/(60*fps);
  
  if(bank<-bankDeadzone || bank>bankDeadzone) bearing += (1091*tan(radians(bank)))/(speed*fps);
  
  if(debug) printData();
}

public void printData(){
  println("Pitch: "+pitch);
  println("Bank: "+bank);
  println("Cl: "+liftCoefficient);
  println("Cd: "+dragCoefficient);
  println("Lift: "+lift);
  println("Drag: "+drag);
  println("Weight: "+weight*asin(radians(pitch)));
  println("Thrust: "+thrust);
  println("VS: "+fpm);
  println("RPM: "+rpm);
  println("IAS: "+speed);
  println("TAS: "+tas);
  println("Incidence: "+incidence);
  println("AOA: "+aoa);
  //println("Power: "+power);
  println("AccelerationX: "+accelerationX*acos(radians(pitch)));
  println("AccelerationY: "+accelerationY*asin(radians(pitch)));
  println("Acceleration: "+acceleration);
  println("L/D: "+lift/drag);
  println("Turn rate/s: "+(1091*tan(radians(bank)))/(speed));
  println("");
}
class Horizon{
  float x, y;
  
  int horizonWidth = 400;
  
  float horizonInsideScale = 0.98f;
  float horizonInsideWidth = horizonWidth*horizonInsideScale;
  
  float bankCenterLineSize = horizonWidth/55;
  float bankHorizontalLineSize = horizonWidth/55;
  
  float bankIndSize = horizonWidth/20;
  float bankIndOffset = 2;//horizonWidth/60;
  
  float horizonInsideScale2 = 0.75f;
  float horizonInsideWidth2 = horizonWidth*horizonInsideScale2;
  
  float pitchCenterLineSize = horizonWidth/100;
  float pitchLineSpacing = horizonWidth/20;
  float pitchLineS = horizonWidth/10;
  float pitchLineL = horizonWidth/4.76f;
  float pitchLineHeight = 5;
  int pitchAngles = 6;
  
  float attIndWidth = horizonWidth/3.333f;
  float attIndHeight = horizonWidth/25;
  float attIndSpace = horizonWidth/12.5f;
  float attIndThickness = horizonWidth/50;
  
  int groundColorExt = 0xff9F6900;
  int skyColorExt = 0xff00BDEC;
  int groundColorInt = 0xff946200;
  int skyColorInt = 0xff00B6E3;
  int bankIndColor = 0xffF07F00;
  
  int[] bankAngles = {10,20,30,60};
  
  Horizon(float x, float y)
  {
    this.x = x;
    this.y = y;
  };
  
  public void displayFixed(){
  }
  
  public void display(float pitch, float bank){
    displayFixed();
    noStroke();
    
    pushMatrix();
    translate(x,y);
    rotate(radians(bank));
    
    displayInnerEnvFixed();
    
    pushMatrix();
    translate(0,pitch*(pitchLineSpacing/(pitchAngles-1)));
    
    displayInnerEnv();
    
    //Center line
    fill(255);
    rectMode(CENTER);
    rect(0,0,horizonInsideWidth2,pitchCenterLineSize);
    
    displayPitchAngles();
    
    popMatrix();
    popMatrix();
    
    displayAttitudeIndicator();
    
    displayOutterEnv();
    
    displayBankLines();
    
    pushMatrix();
    translate(x,y);
    rotate(radians(bank));
    displayBankIndicator();
    popMatrix();
    
    displayOutterRing();
  }
  
  public void displayInnerEnv(){
    noStroke();
    
    //Sky half
    fill(skyColorInt);
    arc(0,0,horizonInsideWidth2*1.15f,horizonInsideWidth2*0.85f,PI,TWO_PI);
    
    //Ground half
    fill(groundColorInt);
    arc(0,0,horizonInsideWidth2*1.15f,horizonInsideWidth2*0.85f,0,PI);
  }
  
  public void displayInnerEnvFixed(){
    noStroke();
    rectMode(CORNER);
    
    //Sky half
    fill(skyColorInt);
    arc(0,0,horizonInsideWidth2*1.01f,horizonInsideWidth2*1.01f,PI,TWO_PI);
    
    //Ground half
    fill(groundColorInt);
    arc(0,0,horizonInsideWidth2*1.01f,horizonInsideWidth2*1.01f,0,PI);
  }
  
  public void displayPitchAngles(){
    //Pitch angles
    stroke(255);
    strokeWeight(pitchLineHeight);
    strokeCap(ROUND);
    float pitchLineLength;
    
    for(int i=1; i<=pitchAngles; i++){
      if(i%2 == 1)
        pitchLineLength = pitchLineS;
      else
        pitchLineLength = pitchLineL;
        
      line(0-pitchLineLength/2,0-pitchLineSpacing*i,0+pitchLineLength/2,0-pitchLineSpacing*i);
      line(0-pitchLineLength/2,0+pitchLineSpacing*i,0+pitchLineLength/2,0+pitchLineSpacing*i);
    }
  }
  
  public void displayAttitudeIndicator(){
    stroke(0);
    strokeWeight(attIndThickness);
    strokeCap(SQUARE);
    
    line(x-attIndWidth,y,x-attIndSpace,y);
    line(x-attIndSpace-attIndThickness/2,y,x-attIndSpace-attIndThickness/2,y+attIndHeight);
    
    line(x+attIndWidth,y,x+attIndSpace,y);
    line(x+attIndSpace+attIndThickness/2,y,x+attIndSpace+attIndThickness/2,y+attIndHeight);
    
    noStroke();
    
    rectMode(CENTER);
    fill(0);
    rect(x,y,attIndThickness,attIndThickness);
  }
  
  public void displayBankLines(){
    stroke(255);
    strokeWeight(bankCenterLineSize);
    strokeCap(SQUARE);
    
    pushMatrix();
    translate(x,y);
    line(0,-horizonInsideWidth2/2,0,-horizonWidth/2*horizonInsideScale);
    
    float bankLineScale;
    
    for(int i=0; i<bankAngles.length; i++){
      if(i>1){
        strokeWeight(6);
        bankLineScale = 1;
      }else{
        strokeWeight(4);
        bankLineScale = 0.92f; 
      }
      pushMatrix();
      rotate(radians(bankAngles[i]));
      line(0,-horizonInsideWidth2/2,0,-horizonWidth/2*horizonInsideScale*bankLineScale);
      popMatrix();
      
      pushMatrix();
      rotate(radians(-bankAngles[i]));
      line(0,-horizonInsideWidth2/2,0,-horizonWidth/2*horizonInsideScale*bankLineScale);
      popMatrix();
    }
    popMatrix();
    
    //Bank horizontal line
    noStroke();
    fill(255);
    rectMode(CORNER);
    rect(x-horizonInsideWidth/2,y-bankHorizontalLineSize/2,(horizonInsideWidth-horizonInsideWidth2)/2,bankHorizontalLineSize);
    rect(x+horizonInsideWidth/2,y-bankHorizontalLineSize/2,-(horizonInsideWidth-horizonInsideWidth2)/2,bankHorizontalLineSize);
  }
  
  public void displayBankIndicator(){
    noFill();
    stroke(bankIndColor);
    strokeWeight(4);
    triangle(
      0,-horizonWidth/2*horizonInsideScale2-bankIndOffset,
      -bankIndSize/2,-horizonWidth/2*horizonInsideScale2+bankIndSize-bankIndOffset,
      bankIndSize/2,-horizonWidth/2*horizonInsideScale2+bankIndSize-bankIndOffset
    );
    noStroke();
  }
  
  public void displayOutterEnv(){
    //Sky
    noFill();
    stroke(skyColorExt);
    strokeWeight((horizonInsideWidth-horizonInsideWidth2)/2);
    arc(x,y,horizonInsideWidth2+(horizonInsideWidth-horizonInsideWidth2)/2*1.01f,horizonInsideWidth2+(horizonInsideWidth-horizonInsideWidth2)/2,PI,TWO_PI);
    
    //Ground
    stroke(groundColorExt);
    arc(x,y,horizonInsideWidth2+(horizonInsideWidth-horizonInsideWidth2)/2*1.01f,horizonInsideWidth2+(horizonInsideWidth-horizonInsideWidth2)/2,0,PI);
    noStroke();
  }
  
  public void displayOutterRing(){
    //fill(0);
    noFill();
    stroke(0);
    strokeWeight(horizonWidth-horizonInsideWidth);
    ellipse(x,y,horizonWidth,horizonWidth);
    stroke(255);
    strokeWeight(2);
    ellipse(x,y,horizonWidth-(horizonWidth-horizonInsideWidth),horizonWidth-(horizonWidth-horizonInsideWidth));
  }
  
}
class InstructionHandler{
  int currentAltAction, currentTurnAction;
  float targetAltitude, currentAltitude;
  float targetBearing, currentBearing;
  String targetBearingText;
  
  float[] altRate = {800,1600,0};
  //float[][] turnRate = {{4.8,8},{4.8,7.8},{4.5,7}};
  float[] turnRate = {4.5f,7};
  
  String turn;
  int altitudeDelta = 1000;
  int bankAngle, turnRadius;
  
  InstructionHandler(float startAltitude, float startBearing){
    currentAltitude = startAltitude;
    currentBearing = startBearing;
  }
  
  public String getTextBearing(int bearing){
    String result;
    
    switch(bearing){
      case 0: result = "NORD";
      break;
      
      case 90: result = "EST";
      break;
      
      case 180: result = "SUD";
      break;
      
      case 270: result = "OUEST";
      break;
      
      default: result = "Invalid bearing"; 
    }
    return result;
  }
  
  public String getRandomAltitudeInstruction(){
    String result;
    int rand = PApplet.parseInt(random(100));
    
    if(rand>=0 && rand<45 && currentAltitude>2000){
      result = setDescent();
    }else if(rand>=45 && rand<90 || currentAltitude<=2000){
      result = setClimb();
    }else if(currentAltAction == 2){
      if(rand>50) result = setDescent();
      else result = setClimb();
    }else{
      result = setLevel();
    }
    //currentAltitude = targetAltitude;
    return result;
  }
  
  public String setDescent(){
    currentAltAction = 0;
    currentAltitude -= altitudeDelta;
    return "DESCENDRE "+PApplet.parseInt(currentAltitude)+" FT | -5° | 700 RPM | 98";
  }
  
  public String setClimb(){
    currentAltAction = 1;
    currentAltitude += altitudeDelta;
    return "MONTER "+PApplet.parseInt(currentAltitude)+" FT | 10° | PLEIN GAZ | 54";
  }
  
  public String setLevel(){
    currentAltAction = 2;
    return "PALIER "+PApplet.parseInt(currentAltitude)+" FT | 1200 RPM | NN";
  }
  
  public String getRandomTurnInstruction(){
    String result;
    int rand = PApplet.parseInt(random(100));
    int rand2 = PApplet.parseInt(random(2));
    int rand3 = PApplet.parseInt(random(2));
    
    if(rand2 == 0){
      bankAngle = 20;
      currentTurnAction = 0;
    } else {
      bankAngle = 30;
      currentTurnAction = 1;
    }
    
    if(rand3 == 0) turn = "GAUCHE";
    else turn = "DROITE";
    
    if(rand<=10){
      result = "EFFECTUER 360 | "+turn+" | "+bankAngle+"°";
      turnRadius = 360;
    }else if(rand<=35){
      result = "MAINTENIR LE CAP";
      turnRadius = 0;
    }else if(targetBearing == 0){
      targetBearing = 180;
      result = "CAP SUD | "+turn+" | "+bankAngle+"°";
      turnRadius = 180;
    }else if(targetBearing == 180){
      targetBearing = 0;
      result = "CAP NORD | "+turn+" | "+bankAngle+"°";
      turnRadius = 180;
    }else result = "Cap invalide";
    
    return result;
  }
  
  public float getAltTime(){
    return altRate[currentAltAction];
  }
  
  public float getTurnTime(){
    return turnRate[currentTurnAction];
  }
  
  public int getAltitudeDelta(){
    return altitudeDelta;
  }
  
  public int getTurnRadius(){
    return turnRadius;
  }
  
}
String saveFileName = "data/joystick.json";
boolean fileExists = true;

String savedTolerance = "tolerance";
String savedJoystick = "joystick";
String savedThrottle = "throttle";
String savedMultiplier = "multiplier";
String savedAxis = "axis";

ControlIO control;
ControlDevice stickDevice, throttleDevice;
float x, y, throttle;
String stickName, throttleName;

boolean validStick = false;
boolean validThrottle = false;

boolean stickAxesSet = false;
boolean throttleAxesSet = false;

int textSize = 30;

float toleranceMin = 0;
float toleranceMax = 0.1f;
float xTolerance = 0;
float yTolerance = 0;
float tTolerance = 0;

int xInverse = 1;
int yInverse = 1;
int tInverse = -1;

float panelX = 1000;
float panelY = 600;

float yAlign = 5;

int panelBorder = 3;

int backgroundColor = 0xff97C4EC;

DropdownList stickDropdown, throttleDropdown, xAxisDropdown, yAxisDropdown, tAxisDropdown;
List deviceList, axisList;
ControlSlider sliderX, sliderY, sliderT;
String[] stickList = {};
String[] stickAxesNames = {};
String[] throttleAxesNames = {};
Checkbox invertPitchCheckbox, invertRollCheckbox, invertThrotCheckbox;
Slider toleranceSliderX, toleranceSliderY, toleranceSliderT;

Button validateButton;

JSONObject data,tolerance,multiplier,axis;

boolean preloadFinished = false;

public void setupJoystick(){
  deviceList = control.getDevices();
  
  data = new JSONObject();
  tolerance = new JSONObject();
  multiplier = new JSONObject();
  axis = new JSONObject();
  for(int i=0; i<deviceList.size(); i++){
    if(control.getDevice(i).getTypeName() == "Stick") stickList = append(stickList,deviceList.get(i).toString());
  }
  
  stickDropdown = new DropdownList(width/2,height/3,580,100,"Joystick",stickList);
  stickDropdown.setColor(color(0xff6FB4F0));
  stickDropdown.setTextSize(23);
  
  throttleDropdown = new DropdownList(width/2+580/2+10,height/3,580,100,"Mannette des gaz",stickList);
  throttleDropdown.setColor(color(0xff6FB4F0));
  throttleDropdown.setTextSize(23);
  
  xAxisDropdown = new DropdownList(panelX*1.07f,panelY*(yAlign+0.6f)/6,300,70,"Sélectionner");
  yAxisDropdown = new DropdownList(panelX/1.2f,panelY*(yAlign+0.6f)/6,300,70,"Sélectionner");
  tAxisDropdown = new DropdownList(panelX*1.3f,panelY*(yAlign+0.6f)/6,300,70,"Sélectionner");
  
  invertPitchCheckbox = new Checkbox(panelX/1.2f,panelY*(yAlign+2.4f)/6);
  invertRollCheckbox = new Checkbox(panelX*1.07f,panelY*(yAlign+2.4f)/6);
  invertThrotCheckbox = new Checkbox(panelX*1.3f,panelY*(yAlign+2.4f)/6);
  invertThrotCheckbox.setActive(true);
  
  toleranceSliderX = new Slider(panelX*1.07f,panelY*(yAlign+1.8f)/6,50);
  toleranceSliderX.setBoundaries(toleranceMin,toleranceMax);
  
  toleranceSliderY = new Slider(panelX/1.2f,panelY*(yAlign+1.8f)/6,50);
  toleranceSliderY.setBoundaries(toleranceMin,toleranceMax);
  
  toleranceSliderT = new Slider(panelX*1.3f,panelY*(yAlign+1.8f)/6,50);
  toleranceSliderT.setBoundaries(toleranceMin,toleranceMax);
  
  validateButton = new Button("Valider",width/2+panelX/2-100, height/2+panelY/2-40);
  validateButton.setSize(200,80);
  validateButton.setColor(color(0xff6FB4F0));
}

public void checkValidStick(){
  try {
    if(control.getDevice(stickName) != stickDevice){
      stickAxesSet = false;
      sliderY = null;
      sliderX = null;
    }
    stickDevice = control.getDevice(stickName);
    if(stickDevice.getTypeName() == "Stick"){
      validStick = true;
    } else validStick = false;
  } catch(RuntimeException e){
    validStick = false;
  }
}

public void checkValidThrottle(){
  try {
    if(control.getDevice(throttleName) != throttleDevice){
      throttleAxesSet = false;
      sliderT = null;
    }
    throttleDevice = control.getDevice(throttleName);
    if(throttleDevice.getTypeName() == "Stick") validThrottle = true;
    else validThrottle = false;
  } catch(RuntimeException e){
    validThrottle = false;
  }
}

public void displayJoystickConfig(){
  if(fileExists)
    if(loadStrings(saveFileName)!=null){
      if(loadFromFile()){
        if(!joystickPreloaded){
          joystickSet = true;
          joystickPreloaded = true;
          return;
        }else{
          if(!preloadFinished) joystickPreload();
        }
      }
    } else fileExists = false;
  
  //Background
  rectMode(CENTER);
  stroke(0);
  strokeWeight(panelBorder);
  fill(backgroundColor);
  rect(width/2,height/2,panelX,panelY);
  
  stickName = stickDropdown.buttons[0].text;
  throttleName = throttleDropdown.buttons[0].text;
  
  checkValidStick();
  checkValidThrottle();
  
  if(validStick){
    if(!stickAxesSet) setStickAxes();
    
    if(xAxisDropdown.getSelection() != xAxisDropdown.firstElement){
      sliderX = stickDevice.getSlider(xAxisDropdown.getSelection());
      configureXAxis();
      getXInput();
    }
    
    if(yAxisDropdown.getSelection() != yAxisDropdown.firstElement){
      sliderY = stickDevice.getSlider(yAxisDropdown.getSelection());
      configureYAxis();
      getYInput();
    }
    
    textSize(textSize);
    textAlign(CENTER,CENTER);
    
    if(sliderY != null){
      textSize(textSize);
      fill(0);
      text(y,panelX/1.2f,panelY*(yAlign+1.2f)/6);
      invertPitchCheckbox.display();
      toleranceSliderY.display();
    }
    
    if(sliderX != null){
      textSize(textSize);
      fill(0);
      text(x,panelX*1.07f,panelY*(yAlign+1.2f)/6);
      invertRollCheckbox.display();
      toleranceSliderX.display();
    }
    
    yAxisDropdown.display();
    xAxisDropdown.display();
  }else{
    fill(0);
    textSize(textSize);
    text("Sélectionner un joystick valide",width/2,height/4);
  }
  
  if(validThrottle){
    if(!throttleAxesSet) setThrottleAxes();
    
    if(tAxisDropdown.getSelection() != tAxisDropdown.firstElement){
      sliderT = throttleDevice.getSlider(tAxisDropdown.getSelection());
      configureTAxis();
      getTInput();
    }
    
    textSize(textSize);
    textAlign(CENTER,CENTER);
      
    if(sliderT != null){
      textSize(textSize);
      fill(0);
      text(throttle,panelX*1.3f,panelY*(yAlign+1.2f)/6);
      invertThrotCheckbox.display();
      toleranceSliderT.display();
    }
    
    tAxisDropdown.display();
  }else{
    fill(0);
    textSize(textSize);
    text("Sélectionner une manette des gaz valide",width/2,height/3.6f);
  }
  
  stickDropdown.display();
  throttleDropdown.display();
  
  fill(0);
  textSize(textSize+8);
  text("Axe A",panelX/1.6f,panelY*(yAlign)/6);
  text("Axe J",panelX/1.6f,panelY*(yAlign+0.6f)/6);
  text("Valeur",panelX/1.6f,panelY*(yAlign+1.2f)/6);
  text("Deadzone",panelX/1.6f,panelY*(yAlign+1.8f)/6);
  text("Inverser",panelX/1.6f,panelY*(yAlign+2.4f)/6);
  
  text("Gaz",panelX*1.3f,panelY*(yAlign)/6);
  text("Tangage",panelX/1.2f,panelY*(yAlign)/6);
  text("Roulis",panelX*1.07f,panelY*(yAlign)/6);
  
  validateButton.display();
    if(validateButton.clicked) validate();
}

public void setStickAxes(){
  stickAxesNames = new String[0];
  for(int i= 0; i<stickDevice.getNumberOfSliders();i++)
    stickAxesNames = append(stickAxesNames,stickDevice.getSlider(i).getName());
    
  xAxisDropdown.setElements(stickAxesNames);
  xAxisDropdown.setColor(color(0xff6FB4F0));
  xAxisDropdown.setTextSize(23);
  
  yAxisDropdown.setElements(stickAxesNames);
  yAxisDropdown.setColor(color(0xff6FB4F0));
  yAxisDropdown.setTextSize(23);
  
  stickAxesSet = true;
}

public void setThrottleAxes(){
  throttleAxesNames = new String[0];
  for(int i= 0; i<throttleDevice.getNumberOfSliders();i++)
    throttleAxesNames = append(throttleAxesNames,throttleDevice.getSlider(i).getName());
  
  tAxisDropdown.setElements(throttleAxesNames);
  tAxisDropdown.setColor(color(0xff6FB4F0));
  tAxisDropdown.setTextSize(23);
  
  throttleAxesSet = true;
}

public void validate(){
  saveToFile();
  resetFlight();
  joystickSet = true;
}

public void joystickPreload(){
  stickDropdown.buttons[0].setText(stickDevice.getName());
  throttleDropdown.buttons[0].setText(throttleDevice.getName());
  
  checkValidStick();
  
  if(validStick){
    xAxisDropdown.buttons[0].setText(sliderX.getName());
    toleranceSliderX.setValue(sliderX.getTolerance());
    invertRollCheckbox.setActive(sliderX.getMultiplier()==-1);
    
    yAxisDropdown.buttons[0].setText(sliderY.getName());
    toleranceSliderY.setValue(sliderY.getTolerance());
    invertPitchCheckbox.setActive(sliderY.getMultiplier()==-1);
  }
  
  checkValidThrottle();
  
  if(validThrottle){
    tAxisDropdown.buttons[0].setText(sliderT.getName());
    toleranceSliderT.setValue(sliderT.getTolerance());
    invertThrotCheckbox.setActive(sliderT.getMultiplier()==-1);
  }
  
  if(validStick && validThrottle) preloadFinished = true;
}

public void saveToFile(){
  data.setString(savedJoystick,stickName);
  data.setString(savedThrottle,throttleName);
  
  data.setFloat(savedTolerance+"X",toleranceSliderX.getValue());
  data.setFloat(savedTolerance+"Y",toleranceSliderY.getValue());
  data.setFloat(savedTolerance+"T",toleranceSliderT.getValue());
  
  data.setInt(savedMultiplier+"X",xInverse);
  data.setInt(savedMultiplier+"Y",yInverse);
  data.setInt(savedMultiplier+"T",tInverse);
  
  data.setString(savedAxis+"X",sliderX.getName());
  data.setString(savedAxis+"Y",sliderY.getName());
  data.setString(savedAxis+"T",sliderT.getName());

  saveJSONObject(data,saveFileName);
}

public boolean loadFromFile(){
  data = loadJSONObject(saveFileName);
  
  try{
    stickDevice = control.getDevice(data.getString(savedJoystick));
    throttleDevice = control.getDevice(data.getString(savedThrottle));
  } catch(RuntimeException e){
    return false;
  }
  
  sliderX = stickDevice.getSlider(data.getString(savedAxis+"X"));
  sliderY = stickDevice.getSlider(data.getString(savedAxis+"Y"));
  sliderT = throttleDevice.getSlider(data.getString(savedAxis+"T"));
  
  sliderX.setTolerance(data.getFloat(savedTolerance+"X"));
  sliderY.setTolerance(data.getFloat(savedTolerance+"Y"));
  sliderT.setTolerance(data.getFloat(savedTolerance+"T"));
  
  sliderX.setMultiplier(data.getInt(savedMultiplier+"X"));
  sliderY.setMultiplier(data.getInt(savedMultiplier+"Y"));
  sliderT.setMultiplier(data.getInt(savedMultiplier+"T"));
  
  return true;
}

public void configureYAxis(){
  sliderY.setTolerance(toleranceSliderY.getValue());
  if(invertPitchCheckbox.active) yInverse = -1; else yInverse = 1;
  sliderY.setMultiplier(yInverse);
}

public void configureXAxis(){
  sliderX.setTolerance(toleranceSliderX.getValue());
  if(invertRollCheckbox.active) xInverse = -1; else xInverse = 1;
  sliderX.setMultiplier(xInverse);
}

public void configureTAxis(){
  sliderT.setTolerance(toleranceSliderT.getValue());
  if(invertThrotCheckbox.active) tInverse = -1; else tInverse = 1;
  sliderT.setMultiplier(tInverse);
}

public void getUserInput(){
  getXInput();
  getYInput();
  getTInput();
}

public void getXInput(){
  x = sliderX.getValue();
}

public void getYInput(){
  y = sliderY.getValue();
}

public void getTInput(){
  throttle = sliderT.getValue();
}

public void selectJoystick(){
  int sliders = control.getDevice(6).getNumberOfSliders();
  
  for(int i=0; i<sliders;i++){
    println("Axe "+i+": "+control.getDevice(6).getSlider(i));
  }
}
class Rotactor{
  //Init draw parameters
  float x, y;
  
  int rotactorWidth = 170;
  float rotactorTurnScale = 0.45f;
  float rotactorTurnWidth = rotactorWidth*rotactorTurnScale;
  
  int rotactorTextSize = 30;
  
  int rotactorLineThickness = 5;
  float rotactorLineScale = 0.75f;
  
  float rotactorAngleStart = radians(150);
  float rotactorAngleStep = radians(35);
  
  
  //Init logic parameters
  int rotactorSelection = 0;
  
  String[] text;
  String selection;
  
  Rotactor(float x, float y, String[] text){
    this.text = text;
    this.x = x;
    this.y = y;
  }
  
  public void displayFixed(){
    textSize(rotactorTextSize);
    textAlign(CENTER,CENTER);
    
    stroke(255);
    strokeWeight(2);
    
    fill(0);
    ellipse(x,y,rotactorWidth,rotactorWidth);
    
    fill(30);
    ellipse(x,y,rotactorTurnWidth,rotactorTurnWidth);
    
    noStroke();
    
    fill(255);
    for(int i=0; i<text.length; i++){
      text(text[i],
        x+(rotactorWidth/2-(rotactorWidth-rotactorTurnWidth)/4)*cos(rotactorAngleStart+i*rotactorAngleStep),
        y+(rotactorWidth/2-(rotactorWidth-rotactorTurnWidth)/4)*sin(rotactorAngleStart+i*rotactorAngleStep)
      );
    }
  }
  
  public void display(int rotactorSelection){
    displayFixed();
    
    pushMatrix();
    translate(x,y);
    
    selection = text[rotactorSelection];
    rotate(rotactorAngleStart+PI+rotactorAngleStep*rotactorSelection);
    stroke(255);
    strokeWeight(rotactorLineThickness);
    line(0-rotactorTurnWidth/2*(1-rotactorLineScale),0,0-rotactorTurnWidth/2,0);
    
    popMatrix();
    
    noStroke();
  }
}
class Slider{
  
  SliderButton sButton;
  float x, y, min, max, size;
  float thickness = 2;
  float textOffset = 50;
  float textSize = 20;
  int textColor = color(0);
  
  boolean displayText = true;
  
  Slider(float x, float y, float size){
    this.x = x;
    this.y = y;
    this.size = size;
    sButton = new SliderButton(x-size/2,y,50,50);
  }
  
  public void display(){
    checkClicks();
    stroke(0);
    strokeWeight(thickness);
    line(x-size/2,y,x+size/2,y);
    sButton.display();
    if(displayText){
      textSize(textSize);
      fill(textColor);
      text(nfc(getValue()*100,2),x+size/2+textOffset,y);
      //map(button.x,x-size/2,x+size/2,min,max)
    }
  }
  
  public float getValue(){
    return map(sButton.x,x-size/2,x+size/2,min,max);
  }
  
  public void setValue(float value){
    sButton.setPosition(map(value,min,max,x-size/2,x+size/2),sButton.y);
  }
  
  public void checkClicks(){
    if(sButton.clicked && sButton.x<=x+size/2 && sButton.x>=x-size/2){
        sButton.setPosition(mouseX,y);
        if(sButton.x<x-size/2) sButton.setPosition(x-size/2,y);
        if(sButton.x>x+size/2) sButton.setPosition(x+size/2,y);
    }
  }
  
  public void setBoundaries(float min, float max){
    this.min = min;
    this.max = max;
  }
}
class SliderButton{
  
  boolean clicked;
  
  float x,y;
  
  float buttonWidth;
  float buttonHeight;
  
  float buttonBorder = 1;
  
  int defaultBackgroundColor, hoverBackgroundColor, clickedBackgroundColor;
  int textColor = color(0);
  
  SliderButton(float x, float y, float buttonWidth, float buttonHeight){
    this.x = x;
    this.y = y;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    
    setColor(color(255));
  }
  
  SliderButton(float x, float y){
    this(x,y,100,100);
  }
  
  public void setColor(int newColor){
    defaultBackgroundColor = newColor;
    hoverBackgroundColor = color(red(defaultBackgroundColor),green(defaultBackgroundColor)-10,blue(defaultBackgroundColor)-30);
    clickedBackgroundColor = color(red(defaultBackgroundColor),green(defaultBackgroundColor)-10,blue(hoverBackgroundColor)-30);
  }
  
  public void setTextColor(int textColor){
    this.textColor = textColor;
  }
  
  public void setPosition(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public void display(float x, float y){
    checkMouse();
    rectMode(CENTER);
    stroke(0);
    strokeWeight(buttonBorder);
    textAlign(CENTER,CENTER);
    textSize(textSize);
    rect(x,y,buttonWidth/2,buttonHeight/2);
    fill(textColor);
  }
  
  public void display(){
    display(x,y);
  }
  
  public void setSize(float buttonWidth, float buttonHeight){
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
  }
  
  public void checkMouse(){
    if(overRect(x,y,buttonWidth/4,buttonHeight/4) || clicked){
       fill(hoverBackgroundColor);
       if(leftMouseClicked){
         fill(clickedBackgroundColor);
         if(!mouseLocked){
           clicked = true;
           mouseLocked = true;
         }
       } else clicked = false;
    } else {
      fill(defaultBackgroundColor);
      clicked = false;
    }
  }
  
  public boolean overRect(float x, float y, float lWidth, float lHeight) {
    if (mouseX >= x-lWidth && mouseX <= x+lWidth && mouseY >= y-lHeight && mouseY <= y+lHeight) return true;
    else return false;
  }
}
class Tachometer{
  float x, y;
  
  int tachoWidth = 350;
  float tachoInsideScale = 0.95f;
  float tachoInsideWidth = tachoWidth*tachoInsideScale;
  
  int smallLineLength = 12;
  int smallLineWidth = 2;
  
  int bigLineLength = 25;
  int bigLineWidth = 5;
  
  int tachoTextOffset = 25;
  int tachoTextSize = 30;
  
  float maxRpm = 35;
  
  float tachoAngleStart = radians(230);
  float tachoAngleSpacing = radians(50);
  float tachoAngleStep;
  
  float needleScale = 0.80f;
  float needleLength = tachoInsideWidth/2*needleScale;
  int needleWidth = 10;
  float needleTipLength = 20;
  float needleCornerAngle = 360;
  int needleCacheWidth = 20;
  int needleOffset = 5;
  
  Tachometer(float x, float y){
    this.x = x;
    this.y = y;
    
    tachoAngleStep = (TWO_PI-tachoAngleSpacing*2)/maxRpm;
    
    strokeCap(SQUARE);
  }
  
  public void displayFixed(){
    noStroke();
    
    //Outter circle
    fill(0);
    ellipse (x,y,tachoWidth,tachoWidth);
    
    //Inner circle
    strokeWeight(2);
    stroke(255);
    fill(20);
    ellipse (x,y,tachoInsideWidth,tachoInsideWidth);
    
    
    for(int i=0; i<=maxRpm; i++){
      pushMatrix();
      translate(x,y);
      rotate(i*tachoAngleStep+tachoAngleStart);
      
      stroke(255);
      
      if(i%5 == 0){
        strokeWeight(bigLineWidth);
        line(0,0-tachoInsideWidth/2+bigLineLength,0,0-tachoInsideWidth/2);
        
        popMatrix();
        
        fill(255);
        float angle = i*tachoAngleStep+tachoAngleStart+PI/2;
        textSize(tachoTextSize);
        textAlign(CENTER,CENTER);
        text(i,x-(tachoInsideWidth/2-bigLineLength-tachoTextOffset)*cos(angle),y-(tachoInsideWidth/2-bigLineLength-tachoTextOffset)*sin(angle));
        
        pushMatrix();
        translate(x,y);
        rotate(i*tachoAngleStep+tachoAngleStart);
      } else {
        strokeWeight(smallLineWidth);
        line(0,0-tachoInsideWidth/2+smallLineLength,0,0-tachoInsideWidth/2);
      }
      popMatrix();
    }
    
    textSize(titleTextSize);
    text("RPM",x,y+titleTextOffset);
    text("x100",x,y+titleTextOffset*2);
  }
  
  public void display(float rpm){
    displayFixed();
    
    noStroke();
    pushMatrix();
    translate(x,y);
    rotate(rpm*tachoAngleStep+tachoAngleStart);
    
    //Needle
    rect(-needleWidth/2,needleOffset,needleWidth,-needleLength,0,0,needleCornerAngle,needleCornerAngle);
    triangle(-needleWidth/2,-needleLength*0.995f+needleOffset,needleWidth/2,-needleLength*0.995f+needleOffset,0,-needleLength-needleTipLength);
    
    popMatrix();
    
    noStroke();
    ellipse(x,y,needleCacheWidth,needleCacheWidth);
  }
}
class Vario{
  float x, y;
  
  int varioWidth = 350;
  float varioInsideScale = 0.95f;
  float varioInsideWidth = varioWidth*varioInsideScale;
  
  int smallLineLength = 23;
  int smallLineWidth = 2;
  
  int bigLineLength = 30;
  int bigLineWidth = 3;
  
  int textSize = 25;
  
  int varioMax = 25;
  int lineStep = 1;
  int textStep = 5;
  
  float varioAngleStart = radians(270);
  float varioAngleSpacing = radians(25);
  float varioAngleStep = (TWO_PI-varioAngleSpacing*2)/(varioMax*2);
  
  float needleScale = 0.80f;
  float needleLength = varioInsideWidth/2*needleScale;
  int needleWidth = 10;
  float needleTipLength = 20;
  float needleCornerAngle = 360;
  int needleCacheWidth = 20;
  int needleOffset = 5;
  
  Vario(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public void displayFixed(){
    noStroke();
    
    strokeCap(SQUARE);
    
    //Outter circle
    fill(0);
    ellipse (x,y,varioWidth,varioWidth);
    
    //Inner circle
    strokeWeight(2);
    stroke(255);
    fill(20);
    ellipse (x,y,varioInsideWidth,varioInsideWidth);
    
    
    for(int i=-varioMax; i<=varioMax; i+=lineStep){
      pushMatrix();
      translate(x,y);
      rotate(i*varioAngleStep+varioAngleStart);
      
      stroke(255);
      
      if(i%textStep == 0){
        strokeWeight(bigLineWidth);
        line(0,0-varioInsideWidth/2+bigLineLength,0,0-varioInsideWidth/2);
        
        popMatrix();
        
        fill(255);
        float angle = i*varioAngleStep+varioAngleStart+PI/2;
        textSize(this.textSize);
        textAlign(CENTER,CENTER);
        text(i,x-(varioInsideWidth/2-bigLineLength-this.textSize)*cos(angle),y-(varioInsideWidth/2-bigLineLength-this.textSize)*sin(angle));
        
        pushMatrix();
        translate(x,y);
        rotate(i*varioAngleStep+varioAngleStart);
      } else {
        strokeWeight(smallLineWidth);
        line(0,0-varioInsideWidth/2+smallLineLength,0,0-varioInsideWidth/2);
      }
      popMatrix();
    }
    
    textSize(titleTextSize);
    text("VERTICAL SPEED",x,y-titleTextOffset);
    text("100 ft/min",x,y+titleTextOffset);
  }
  
  public void display(float fpm){
    displayFixed();
    
    noStroke();
    pushMatrix();
    translate(x,y);
    rotate(fpm/100*varioAngleStep+varioAngleStart);
    
    //Needle
    rect(-needleWidth/2,needleOffset,needleWidth,-needleLength,0,0,needleCornerAngle,needleCornerAngle);
    triangle(-needleWidth/2,-needleLength*0.995f+needleOffset,needleWidth/2,-needleLength*0.995f+needleOffset,0,-needleLength-needleTipLength);
    
    popMatrix();
    
    noStroke();
    ellipse(x,y,needleCacheWidth,needleCacheWidth);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "sepia" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
