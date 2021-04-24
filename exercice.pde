class Exercice{
  InstructionHandler ih;
  SerieHandler sh;
  Calculus calc;
  NumberInput numberInput;
  ImageHandler imageHandler;

  float speedup = 1;

  float timeSinceLastAlt, timeSinceLastTurn, timeSinceLastCalc, timeSinceLastSerie, timeSincePaused;
  float altInterval, turnInterval, calcInterval, serieInterval;

  //Flying
  float defaultAltInterval = 10000/speedup;
  float defaultTurnInterval = 20000/speedup;
  float defaultInterval = 5000/speedup;
  float turnDelayMin = 25000/speedup;
  float turnDelayMax = 30000/speedup;

  //Calculus
  //float defaultCalcInterval = 20000/speedup;
  float defaultResultInterval = 5000/speedup;
  float calcDelayMin = 35000/speedup;
  float calcDelayMax = 75000/speedup;
  boolean calcActive = false;
  boolean resultActive = false;

  //SerieHandler
  float defaultSerieInterval = 15000/speedup;
  float serieDelayMin = 25000/speedup;
  float serieDelayMax = 40000/speedup;
  boolean serieActive = false;
  boolean serieResultActive = false;

  float inputDelay = 25000/speedup;

  float startAltitude = 3000;
  float startBearing = 0;

  //Time to complete flying instruction
  float timeMargin = 0.65;

  String currentInstruction, previousInstruction, currentCalculation, currentSerieNumber;

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
    sh = new SerieHandler();
    calc = new Calculus();
    imageHandler = new ImageHandler();

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
    timeSinceLastSerie += millis() - timeSincePaused;
  }

  void run(){
    if(started && !paused){

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

      //Calculus
      if(millis()-timeSinceLastCalc>calcInterval && !serieActive){
        //if(sh.hasReachedEnd() && serieInterval - millis() - timeSinceLastSerie < defaultInterval) calcInterval += defaultInterval;
        if(!calcActive){
          calcActive = true;
          calculationColor = defaultCalcColor;
          currentCalculation = calc.getRandomCalculation();
          calcInterval = inputDelay;
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
          calcActive = false;
          calcInterval = int(random(calcDelayMin,calcDelayMax));
          resultActive = false;
          currentCalculation = "";
        }
        timeSinceLastCalc = millis();
      }

      //Serie
      if(millis()-timeSinceLastSerie>serieInterval && !calcActive){
        if(!serieActive && !serieResultActive){
          if(!sh.hasReachedEnd()) sh.setNext();
          //else if(sh.hasReachedEnd() && calcInterval - millis() - timeSinceLastCalc < defaultInterval) serieInterval += defaultInterval;
          serieActive = true;
          timeSinceLastSerie = millis();
          serieInterval = defaultSerieInterval;
        }else{
          if(!sh.hasReachedEnd()){
            serieActive = false;
            serieInterval = int(random(serieDelayMin, serieDelayMax));
          }else if(serieResultActive){
            serieResultActive = false;
            serieActive = false;
            sh = new SerieHandler();
            serieInterval = int(random(serieDelayMin, serieDelayMax));
          }else{
            serieResultActive = true;
            timeSinceLastSerie = millis();
            serieInterval = defaultSerieInterval;
          }
        }
      }
    }
    displayCurrentInstruction();
    displayCurrentCalculation();
    if(serieActive) displayCurrentSerieNumber();
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

  void displayCurrentSerieNumber(){
    textSize(50);
    textAlign(CENTER,CENTER);
    fill(0);
    if(!sh.hasReachedEnd()){
      fill(255);
      rectMode(CENTER);
      stroke(0);
      strokeWeight(4);
      rect(width*0.85,height*0.18,75,75);
      fill(0);
      text(sh.getCurrent(),width*0.85,height*0.18-4);
    }else
      if(!serieResultActive) text("SERIE ?",width*0.85,height*0.18-4);
      else{
        int serie = sh.getSerie();
        if(numberInput.getInput() == serie){
          fill(correctColor);
          text("CORRECT",width*0.85,height*0.18-4);
        }else{
          fill(incorrectColor);
          text("INCORRECT",width*0.85,height*0.18-4);
        }
      }
  }

  void start(){
    altInterval = 0;
    turnInterval = int(random(turnDelayMin,turnDelayMax))/speedup;
    calcInterval = int(random(calcDelayMin,calcDelayMax));
    serieInterval = int(random(serieDelayMin, serieDelayMax));
    started = true;
    paused = false;
  }
}
