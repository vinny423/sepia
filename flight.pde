//Flight settings
float bankDeadzone = 0.9;
float pitchDeadzone = 0.05;

////Environment parameters
float airDensity = 1.225; //kg/m^3

////Aircraft parameters
//Performance
float maxRollRate = 0.2; //°/s
float maxPitchRate = 0.1; //°/s
float maxSpeed = 190; //kts
float minSpeed = 0; //kts

float naturalPitch = 0.002;
float naturalBank = 0.001;

//Engine
float maxRpm = 2700;
float idleRpm = 600;
float propDiameter = 70.8661;//75; //Inches
int propPitch = 63; //Inches
int maxPower = 182;
float idlePower = maxPower*0.15;
float power;
float propellerEfficiency = 0.85;

//Wings
float wingArea = 10.85; //m² 16.17
float wingSpan = 8.06; //m 11
float wingAspectRatio = sq(wingSpan)/(wingArea);
float oswaldEfficiencyFactor = 0.7;
float a = radians(TWO_PI);
float b = 0;
float c = 1/(PI*wingAspectRatio*oswaldEfficiencyFactor);
float d = 0.039;

//Forces
float mass = 750; //Kg 900
float g = 9.80665; //m/s²
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
float lift = 0.5*airDensity*sq(speed*0.5144)*liftCoefficient*wingArea; //N

float dragCoefficient = c*sq(liftCoefficient)+d;
float drag = 0.5*airDensity*sq(speed*0.5144)*dragCoefficient*wingArea; //N

float incidence = (2*weight/(airDensity*sq(speed*0.5144)*wingArea)-b)*1/liftCoefficient;
float aoa = pitch-incidence;

float thrust; //= 4.392399*pow(10,-8)*rpm*(pow(propDiameter,3.5)/sqrt(propPitch))*(4.23333*pow(10,-4)*rpm*propPitch-speed*0.5144); //N
float acceleration, accelerationX, accelerationY; //m/s


void resetFlight(){
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

void flight() {
  if(paused) return;
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

  incidence = degrees((2*weight/(airDensity*sq(speed*0.5144)*wingArea)-b)*1/5.5);
  aoa = pitch-incidence;

  tas = speed+altitude/200;

  liftCoefficient = a*(pitch)+b;
  lift = 0.5*airDensity*sq(tas*0.5144)*liftCoefficient*wingArea; //N

  dragCoefficient = c*sq(liftCoefficient)+d;
  drag = 0.5*airDensity*sq(tas*0.5144)*dragCoefficient*wingArea; //N

  //thrust = 4.392399*pow(10,-8)*rpm*(pow(propDiameter,3.5)/sqrt(propPitch))*(4.23333*pow(10,-4)*rpm*propPitch-speed*0.5144); //N Dynamic thrust
  thrust = propellerEfficiency*power*745.6998/(speed*0.5144);

  acceleration = ((thrust-drag)*cos(radians(pitch))-lift*asin(radians(pitch)))/mass;//m/s

  /*float accelerationX = ((thrust-drag)*cos(radians(pitch))-lift*sin(radians(pitch)))/mass;
  float accelerationY = ((thrust-drag)*sin(radians(pitch))+lift*cos(radians(pitch))-weight)/mass;*/

  if(!speedLocked){
    accelerationX = ((thrust-drag)*cos(radians(pitch))+lift*sin(radians(pitch)))/mass;
    accelerationY = ((thrust-drag)*sin(radians(pitch))-lift*cos(radians(pitch))-weight)/mass;

    acceleration = (accelerationX*acos(radians(pitch)) + accelerationY*asin(radians(pitch)));

    speed += acceleration/(fps*0.5144);
  }

  if(pitch<-pitchDeadzone || pitch>pitchDeadzone) fpm = sin(radians(pitch))*speed*101.269;
  else fpm = 0;

  altitude += fpm/(60*fps);

  if(bank<-bankDeadzone || bank>bankDeadzone) bearing += (1091*tan(radians(bank)))/(speed*fps);

  if(debug) printData();
}

void printData(){
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
