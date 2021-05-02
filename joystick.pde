String saveFileName = "data/joystick.json";
boolean fileExists = true;
String keyboardName = "Clavier";

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
float toleranceMax = 0.1;
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

color backgroundColor = #97C4EC;

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

void setupJoystick(){
  deviceList = control.getDevices();

  data = new JSONObject();
  tolerance = new JSONObject();
  multiplier = new JSONObject();
  axis = new JSONObject();
  for(int i=0; i<deviceList.size(); i++){
    if(control.getDevice(i).getTypeName() == "Stick") stickList = append(stickList,deviceList.get(i).toString());
  }

  stickDropdown = new DropdownList(width/2,height/3,580,100,"Joystick",stickList);
  stickDropdown.setColor(color(#6FB4F0));
  stickDropdown.setTextSize(23);

  throttleDropdown = new DropdownList(width/2+580/2+10,height/3,580,100,"Mannette des gaz",stickList);
  throttleDropdown.setColor(color(#6FB4F0));
  throttleDropdown.setTextSize(23);

  xAxisDropdown = new DropdownList(panelX*1.07,panelY*(yAlign+0.6)/6,300,70,"Sélectionner");
  yAxisDropdown = new DropdownList(panelX/1.2,panelY*(yAlign+0.6)/6,300,70,"Sélectionner");
  tAxisDropdown = new DropdownList(panelX*1.3,panelY*(yAlign+0.6)/6,300,70,"Sélectionner");

  invertPitchCheckbox = new Checkbox(panelX/1.2,panelY*(yAlign+2.4)/6);
  invertRollCheckbox = new Checkbox(panelX*1.07,panelY*(yAlign+2.4)/6);
  invertThrotCheckbox = new Checkbox(panelX*1.3,panelY*(yAlign+2.4)/6);
  invertThrotCheckbox.setActive(true);

  toleranceSliderX = new Slider(panelX*1.07,panelY*(yAlign+1.8)/6,50);
  toleranceSliderX.setBoundaries(toleranceMin,toleranceMax);

  toleranceSliderY = new Slider(panelX/1.2,panelY*(yAlign+1.8)/6,50);
  toleranceSliderY.setBoundaries(toleranceMin,toleranceMax);

  toleranceSliderT = new Slider(panelX*1.3,panelY*(yAlign+1.8)/6,50);
  toleranceSliderT.setBoundaries(toleranceMin,toleranceMax);

  validateButton = new Button("Valider",width/2+panelX/2-100, height/2+panelY/2-40);
  validateButton.setSize(200,80);
  validateButton.setColor(color(#6FB4F0));
}

void checkValidStick(){
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

void checkValidThrottle(){
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

void displayJoystickConfig(){
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
      text(y,panelX/1.2,panelY*(yAlign+1.2)/6);
      invertPitchCheckbox.display();
      toleranceSliderY.display();
    }

    if(sliderX != null){
      textSize(textSize);
      fill(0);
      text(x,panelX*1.07,panelY*(yAlign+1.2)/6);
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
      text(throttle,panelX*1.3,panelY*(yAlign+1.2)/6);
      invertThrotCheckbox.display();
      toleranceSliderT.display();
    }

    tAxisDropdown.display();
  }else{
    fill(0);
    textSize(textSize);
    text("Sélectionner une manette des gaz valide",width/2,height/3.6);
  }

  stickDropdown.display();
  throttleDropdown.display();

  fill(0);
  textSize(textSize+8);
  text("Axe A",panelX/1.6,panelY*(yAlign)/6);
  text("Axe J",panelX/1.6,panelY*(yAlign+0.6)/6);
  text("Valeur",panelX/1.6,panelY*(yAlign+1.2)/6);
  text("Deadzone",panelX/1.6,panelY*(yAlign+1.8)/6);
  text("Inverser",panelX/1.6,panelY*(yAlign+2.4)/6);

  text("Gaz",panelX*1.3,panelY*(yAlign)/6);
  text("Tangage",panelX/1.2,panelY*(yAlign)/6);
  text("Roulis",panelX*1.07,panelY*(yAlign)/6);

  validateButton.display();
    if(validateButton.clicked) validate();
}

void setStickAxes(){
  stickAxesNames = new String[0];
  for(int i= 0; i<stickDevice.getNumberOfSliders();i++)
    stickAxesNames = append(stickAxesNames,stickDevice.getSlider(i).getName());

  xAxisDropdown.setElements(stickAxesNames);
  xAxisDropdown.setColor(color(#6FB4F0));
  xAxisDropdown.setTextSize(23);

  yAxisDropdown.setElements(stickAxesNames);
  yAxisDropdown.setColor(color(#6FB4F0));
  yAxisDropdown.setTextSize(23);

  stickAxesSet = true;
}

void setThrottleAxes(){
  throttleAxesNames = new String[0];
  for(int i= 0; i<throttleDevice.getNumberOfSliders();i++)
    throttleAxesNames = append(throttleAxesNames,throttleDevice.getSlider(i).getName());

  tAxisDropdown.setElements(throttleAxesNames);
  tAxisDropdown.setColor(color(#6FB4F0));
  tAxisDropdown.setTextSize(23);

  throttleAxesSet = true;
}

void validate(){
  saveToFile();
  resetFlight();
  joystickSet = true;
}

void joystickPreload(){
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

void saveToFile(){
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

boolean loadFromFile(){
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

void configureYAxis(){
  sliderY.setTolerance(toleranceSliderY.getValue());
  if(invertPitchCheckbox.active) yInverse = -1; else yInverse = 1;
  sliderY.setMultiplier(yInverse);
}

void configureXAxis(){
  sliderX.setTolerance(toleranceSliderX.getValue());
  if(invertRollCheckbox.active) xInverse = -1; else xInverse = 1;
  sliderX.setMultiplier(xInverse);
}

void configureTAxis(){
  sliderT.setTolerance(toleranceSliderT.getValue());
  if(invertThrotCheckbox.active) tInverse = -1; else tInverse = 1;
  sliderT.setMultiplier(tInverse);
}

void getUserInput(){
  getXInput();
  getYInput();
  getTInput();
}

void getXInput(){
  x = sliderX.getValue();
}

void getYInput(){
  y = sliderY.getValue();
}

void getTInput(){
  throttle = sliderT.getValue();
}

void selectJoystick(){
  int sliders = control.getDevice(6).getNumberOfSliders();

  for(int i=0; i<sliders;i++){
    println("Axe "+i+": "+control.getDevice(6).getSlider(i));
  }
}
