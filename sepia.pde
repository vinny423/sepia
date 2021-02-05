import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import java.util.List;

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

void settings() {
  size(1920, 1080);
}

void setup() {
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
  joystickButton.setColor(color(#083471));
  joystickButton.setTextColor(color(255));
  
  resetFlight();
  
  exercice = new Exercice(altitude,bearing);
  
  rpmLocked = false;
  rollLocked = pitchLocked = speedLocked = true;
}

void draw() {
  background(200);
  
  if(joystickSet){
    
    getUserInput();
    flight();
  
    fill(50);
    stroke(0);
    strokeWeight(10);
    rectMode(CORNER);
    rect(0, height, width, -height*0.75, 180, 180, 0, 0);
  
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

void displayInstruments(){
  tacho.display(rpm/100);
  
  altimeter.display(altitude);

  compass.display(bearing);

  horizon.display(pitch, bank);

  airspeed.display(speed);

  vario.display(fpm);

  rotacteurOdd.display(rotacteurOddSelection);
  rotacteurPair.display(rotacteurPairSelection);
}

void reset(){
  rollLocked = pitchLocked = speedLocked = true;
  resetFlight();
  exercice = new Exercice(altitude,bearing);
  println("Exercice reset");
}

void keyPressed() {
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

void validateValues() {
  if (rotacteurOddSelection > textOdd.length-1) rotacteurOddSelection = textOdd.length-1;
  if (rotacteurOddSelection < 0) rotacteurOddSelection = 0;
  if (rotacteurPairSelection > textPair.length-1) rotacteurPairSelection = textPair.length-1;
  if (rotacteurPairSelection < 0) rotacteurPairSelection = 0;
}

/*void mouseClicked(){
  if(mouseButton == LEFT) leftMouseClicked = true;
}*/

void mousePressed(){
  if(mouseButton == LEFT){
    leftMouseClicked = true;
  }
}

void mouseReleased(){
  if(mouseButton == LEFT){
    leftMouseClicked = false;
    mouseLocked = false;
  }
}
