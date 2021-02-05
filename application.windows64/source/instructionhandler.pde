class InstructionHandler{
  int currentAltAction, currentTurnAction;
  float targetAltitude, currentAltitude;
  float targetBearing, currentBearing;
  String targetBearingText;
  
  float[] altRate = {800,1600,0};
  //float[][] turnRate = {{4.8,8},{4.8,7.8},{4.5,7}};
  float[] turnRate = {4.5,7};
  
  String turn;
  int altitudeDelta = 1000;
  int bankAngle, turnRadius;
  
  InstructionHandler(float startAltitude, float startBearing){
    currentAltitude = startAltitude;
    currentBearing = startBearing;
  }
  
  String getTextBearing(int bearing){
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
  
  String getRandomAltitudeInstruction(){
    String result;
    int rand = int(random(100));
    
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
  
  String setDescent(){
    currentAltAction = 0;
    currentAltitude -= altitudeDelta;
    return "DESCENDRE "+int(currentAltitude)+" FT | -5° | 700 RPM | 98";
  }
  
  String setClimb(){
    currentAltAction = 1;
    currentAltitude += altitudeDelta;
    return "MONTER "+int(currentAltitude)+" FT | 10° | PLEIN GAZ | 54";
  }
  
  String setLevel(){
    currentAltAction = 2;
    return "PALIER "+int(currentAltitude)+" FT | 1200 RPM | NN";
  }
  
  String getRandomTurnInstruction(){
    String result;
    int rand = int(random(100));
    int rand2 = int(random(2));
    int rand3 = int(random(2));
    
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
  
  float getAltTime(){
    return altRate[currentAltAction];
  }
  
  float getTurnTime(){
    return turnRate[currentTurnAction];
  }
  
  int getAltitudeDelta(){
    return altitudeDelta;
  }
  
  int getTurnRadius(){
    return turnRadius;
  }
  
}
