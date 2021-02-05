class Horizon{
  float x, y;
  
  int horizonWidth = 400;
  
  float horizonInsideScale = 0.98;
  float horizonInsideWidth = horizonWidth*horizonInsideScale;
  
  float bankCenterLineSize = horizonWidth/55;
  float bankHorizontalLineSize = horizonWidth/55;
  
  float bankIndSize = horizonWidth/20;
  float bankIndOffset = 2;//horizonWidth/60;
  
  float horizonInsideScale2 = 0.75;
  float horizonInsideWidth2 = horizonWidth*horizonInsideScale2;
  
  float pitchCenterLineSize = horizonWidth/100;
  float pitchLineSpacing = horizonWidth/20;
  float pitchLineS = horizonWidth/10;
  float pitchLineL = horizonWidth/4.76;
  float pitchLineHeight = 5;
  int pitchAngles = 6;
  
  float attIndWidth = horizonWidth/3.333;
  float attIndHeight = horizonWidth/25;
  float attIndSpace = horizonWidth/12.5;
  float attIndThickness = horizonWidth/50;
  
  color groundColorExt = #9F6900;
  color skyColorExt = #00BDEC;
  color groundColorInt = #946200;
  color skyColorInt = #00B6E3;
  color bankIndColor = #F07F00;
  
  int[] bankAngles = {10,20,30,60};
  
  Horizon(float x, float y)
  {
    this.x = x;
    this.y = y;
  };
  
  void displayFixed(){
  }
  
  void display(float pitch, float bank){
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
  
  void displayInnerEnv(){
    noStroke();
    
    //Sky half
    fill(skyColorInt);
    arc(0,0,horizonInsideWidth2*1.15,horizonInsideWidth2*0.85,PI,TWO_PI);
    
    //Ground half
    fill(groundColorInt);
    arc(0,0,horizonInsideWidth2*1.15,horizonInsideWidth2*0.85,0,PI);
  }
  
  void displayInnerEnvFixed(){
    noStroke();
    rectMode(CORNER);
    
    //Sky half
    fill(skyColorInt);
    arc(0,0,horizonInsideWidth2*1.01,horizonInsideWidth2*1.01,PI,TWO_PI);
    
    //Ground half
    fill(groundColorInt);
    arc(0,0,horizonInsideWidth2*1.01,horizonInsideWidth2*1.01,0,PI);
  }
  
  void displayPitchAngles(){
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
  
  void displayAttitudeIndicator(){
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
  
  void displayBankLines(){
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
        bankLineScale = 0.92; 
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
  
  void displayBankIndicator(){
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
  
  void displayOutterEnv(){
    //Sky
    noFill();
    stroke(skyColorExt);
    strokeWeight((horizonInsideWidth-horizonInsideWidth2)/2);
    arc(x,y,horizonInsideWidth2+(horizonInsideWidth-horizonInsideWidth2)/2*1.01,horizonInsideWidth2+(horizonInsideWidth-horizonInsideWidth2)/2,PI,TWO_PI);
    
    //Ground
    stroke(groundColorExt);
    arc(x,y,horizonInsideWidth2+(horizonInsideWidth-horizonInsideWidth2)/2*1.01,horizonInsideWidth2+(horizonInsideWidth-horizonInsideWidth2)/2,0,PI);
    noStroke();
  }
  
  void displayOutterRing(){
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
