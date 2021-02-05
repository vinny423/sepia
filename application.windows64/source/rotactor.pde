class Rotactor{
  //Init draw parameters
  float x, y;
  
  int rotactorWidth = 170;
  float rotactorTurnScale = 0.45;
  float rotactorTurnWidth = rotactorWidth*rotactorTurnScale;
  
  int rotactorTextSize = 30;
  
  int rotactorLineThickness = 5;
  float rotactorLineScale = 0.75;
  
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
  
  void displayFixed(){
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
  
  void display(int rotactorSelection){
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
