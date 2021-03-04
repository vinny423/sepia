class Exercice{
  InstructionHandler ih;
  Calculus calc;
  NumberInput numberInput;

  float speedup = 1;

  float timeSinceLastAlt, timeSinceLastTurn, timeSinceLastCalc, timeSincePaused;
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

  float timeMargin = 0.65;

  String currentInstruction, previousInstruction, currentCalculation;

  color textColor = color(0);
  int textSize = 40;

  boolean levelFlight = true;

  String correct = "✓";
  color correctColor = color(0,220,0);

  String incorrect = "X";
  color incorrectColor = color(255,0,0);

  color defaultCalcColor = color(0,0,255);

  String answer;
  color calculationColor = defaultCalcColor;

  Exercice(float startAltitude, float startBearing, NumberInput numberInput){
    ih = new InstructionHandler(startAltitude, startBearing);
    calc = new Calculus();

    this.numberInput = numberInput;
    this.startAltitude = startAltitude;
    this.startBearing = startBearing;
    currentInstruction = "APPUYER SUR ENTREE POUR COMMENCER";
    currentCalculation = "";
    started = false;
  }

  void pause(){
    timeSincePaused = millis();
  }

  void unpause(){
    timeSinceLastCalc += millis() - timeSincePaused;
    timeSinceLastAlt += millis() - timeSincePaused;
    timeSinceLastTurn += millis() - timeSincePaused;
  }

  void run(){
    if(started && !paused){

      //Calculus
      if(millis()-timeSinceLastCalc>calcInterval){
        if(!calcActive){
          calculationColor = defaultCalcColor;
          currentCalculation = calc.getRandomCalculation();
          calcActive = true;
          calcInterval = defaultCalcInterval;
        }else if(!resultActive){
          if(calc.getResult() == numberInput.getInput()){
            answer = correct;
            calculationColor = correctColor;
          }else{
            answer = incorrect;
            calculationColor = incorrectColor;
          }

          currentCalculation = currentCalculation+" = "+calc.getResult()+" "+answer;
          calcInterval = defaultResultInterval;
          resultActive = true;
        }else{
          calcInterval = int(random(calcDelayMin,calcDelayMax));
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

  void displayCurrentInstruction(){
    fill(0);
    textSize(textSize);
    textAlign(CENTER,CENTER);
    text(currentInstruction,width/2,height*0.1);
  }

  void displayCurrentCalculation(){
    fill(calculationColor);
    textSize(textSize);
    textAlign(CENTER,CENTER);
    text(currentCalculation,width/2,height*0.18);
  }

  void start(){
    altInterval = 0;
    turnInterval = int(random(25000,30000))/speedup;
    calcInterval = int(random(calcDelayMin,calcDelayMax));
    started = true;
    paused = false;
  }
}
