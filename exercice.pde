class Exercice{
  InstructionHandler ih;
  
  float speedup = 1;
  
  float timeSinceLastAlt, timeSinceLastTurn;
  float altInterval, turnInterval;
  
  float defaultAltInterval = 10000/speedup;
  float defaultTurnInterval = 20000/speedup;
  float defaultInterval = 5000/speedup;
  
  float startAltitude = 3000;
  float startBearing = 0;
  
  float timeMargin = 0.65;
  
  String currentInstruction;
  String previousInstruction;
  
  color textColor = color(0);
  int textSize = 40;
  
  boolean levelFlight = true;
  
  Exercice(float startAltitude, float startBearing){
    ih = new InstructionHandler(startAltitude, startBearing);
    this.startAltitude = startAltitude;
    this.startBearing = startBearing;
    currentInstruction = "APPUYER SUR ENTREE POUR COMMENCER";
    started = false;
  }
  
  void run(){
    if(started){
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
  }
  
  void displayCurrentInstruction(){
    fill(textColor);
    textSize(textSize);
    textAlign(CENTER,CENTER);
    text(currentInstruction,width/2,height*0.1);
  }
  
  void start(){
    altInterval = 0;//int(random(5,10))*1000;
    turnInterval = int(random(25,30))*1000/speedup;
    started = true;
  }
}
