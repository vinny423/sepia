import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import java.util.List;

//General settings
boolean debug = false;
boolean started = false;
boolean paused = false;
boolean mouseOn = true;
int fps = 60;
boolean joystickSet = false;
boolean joystickPreloaded = false;
boolean leftMouseClicked = false;
boolean keyActive = false;
boolean rotacteurOddLocked = false;
boolean rotacteurPairLocked = false;
char previousKey;
StringList pressedKeys;
boolean mouseLocked = false;
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
NumberInput numberInput;

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

  horizon = new Horizon(width*2/8, height/2);

  compass = new Compass(width*4/8, height/2);

  tacho = new Tachometer(width*1/8, height*4/5);

  airspeed = new Airspeed(width*3/8, height*4/5);

  vario = new Vario(width*5/8, height*4/5);

  numberInput = new NumberInput(width*0.9, height*0.75,450, 100);

  rotacteurOdd = new Rotactor(width/12, height*3/8, textOdd);
  rotacteurPair = new Rotactor(width/12, height*5/9, textPair);

  joystickButton = new Button("j",width-75,height-75,75,75);
  joystickButton.setColor(color(#083471));
  joystickButton.setTextColor(color(255));

  pressedKeys = new StringList();

  resetFlight();

  exercice = new Exercice(altitude,bearing, numberInput);

  rpmLocked = false;
  rollLocked = pitchLocked = speedLocked = true;
}

void draw() {
  background(220);

  if(joystickSet){

    handleKeys();

    println("Odd locked: ",rotacteurOddLocked);
    println("Pair locked: ",rotacteurPairLocked);
    println(pressedKeys,"\n");

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

    numberInput.display();

    exercice.run();

    if(paused){
      fill(0);
      textSize(50);
      text("PAUSE", width*0.93, height*0.05);
    }

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
  exercice = new Exercice(altitude,bearing, numberInput);
  paused = false;
  println("Exercice reset");
}

void pause(){
  paused = true;
  rollLocked = pitchLocked = speedLocked = true;
  exercice.pause();
}

void unpause(){
  paused = false;
  rollLocked = pitchLocked = speedLocked = false;
  exercice.unpause();
}

void keyPressed() {
  char pressedKey = key;

  //Number input
  if (started && !paused && (Character.isDigit(pressedKey) || keyCode == 10 || keyCode == 8)) numberInput.handleInput();

  //Sim main logic
  if(pressedKey == 'r') reset();

  if(pressedKey == 'p' && started) if(!paused) pause();
  else unpause();

  /*if(key == 'm' && started) {println("Mouse toggle"); if(mouseOn) noCursor();
  else cursor(ARROW);}*/

  //Enter key for starting
  if(pressedKey == ENTER && started == false){
    exercice.start();
    rpmLocked = pitchLocked = rollLocked = speedLocked = false;
  }

  //Arrow keys
  if(pressedKey == CODED){
    if(keyCode == UP) pressedKey = 'o';
    if(keyCode == DOWN) pressedKey = 'l';
    if(keyCode == RIGHT) pressedKey = 'k';
    if(keyCode == LEFT) pressedKey = 'm';
  }

  //Normal keys
  if(!keyActive || pressedKey != previousKey && !isPressed(pressedKey)){
    pressedKeys.append(str(pressedKey));
    previousKey = pressedKey;
    keyActive = true;
  }
}

void keyReleased(){
  char releasedKey = key;

  if(releasedKey == CODED){
    if(keyCode == UP) releasedKey = 'o';
    if(keyCode == DOWN) releasedKey = 'l';
    if(keyCode == RIGHT) releasedKey = 'k';
    if(keyCode == LEFT) releasedKey = 'm';
  }

  for(int i=0; i<pressedKeys.size(); i++) if(pressedKeys.get(i).charAt(0) == releasedKey){
    if('z' == pressedKeys.get(i).charAt(0) || 'a' == pressedKeys.get(i).charAt(0)) rotacteurOddLocked = false;
    if('q' == pressedKeys.get(i).charAt(0) || 's' == pressedKeys.get(i).charAt(0)) rotacteurPairLocked = false;
    pressedKeys.remove(i);
    previousKey = ' ';
  }

  if(pressedKeys.size() == 0){
    keyActive = false;
  }
}

void handleKeys(){
  if(started){
    //Axes
    //Pitch
    if(isPressed('l')) pitch += maxPitchRate;
    else if(isPressed('o')) pitch -= maxPitchRate;
    //Roll
    if(isPressed('m')) bank += maxRollRate;
    else if(isPressed('k')) bank -= maxRollRate;

    //Throttle
    if(isPressed('e')){
      keyboardThrottleValue += keyboardThrottleStep;
      if(keyboardThrottleValue>1) keyboardThrottleValue = 1;
    }else if(isPressed('d')){
      keyboardThrottleValue -= keyboardThrottleStep;
      if(keyboardThrottleValue<-1) keyboardThrottleValue = -1;
    }

    //Rotactors
    if(!rotacteurOddLocked){
      if (isPressed('z')){
        rotacteurOddSelection++;
        rotacteurOddLocked = true;
      }
      else if (isPressed('a')){
        rotacteurOddSelection--;
        rotacteurOddLocked = true;
      }
    }

    if(!rotacteurPairLocked){
      if (isPressed('s') && !paused){
        rotacteurPairSelection++;
        rotacteurPairLocked = true;
      } else if (isPressed('q')){
        rotacteurPairSelection--;
        rotacteurPairLocked = true;
      }
    }
  }
}

boolean isPressed(char k){
  boolean result = false;
  for(String listKey : pressedKeys)
    if(k == listKey.charAt(0)){
      result = true;
      break;
    }
  return result;
}

void validateValues() {
  if (rotacteurOddSelection > textOdd.length-1) rotacteurOddSelection = textOdd.length-1;
  if (rotacteurOddSelection < 0) rotacteurOddSelection = 0;
  if (rotacteurPairSelection > textPair.length-1) rotacteurPairSelection = textPair.length-1;
  if (rotacteurPairSelection < 0) rotacteurPairSelection = 0;
}

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
